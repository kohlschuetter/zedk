/** @file
  UnloadUUID
  Copyright 2026 Christian Kohlschuetter

  Inspired by UniversalAMDFormBrowser,
  using the snippet by Sweet_Kitten in https://winraid.level1techs.com/t/tool-universalamdformbrowser/40353/29
**/

#include <Uefi.h>
#include <Library/PcdLib.h>
#include <Library/UefiLib.h>
#include <Library/UefiApplicationEntryPoint.h>

#include <Library/PrintLib.h>
#include <Library/DebugLib.h>
#include <Library/UefiBootServicesTableLib.h>
#include <Library/HandleParsingLib.h>
#include <Protocol/FormBrowser2.h>
#include <Protocol/FormBrowserEx.h>
#include <Protocol/HiiPopup.h>
#include <Protocol/DisplayProtocol.h>

GLOBAL_REMOVE_IF_UNREFERENCED EFI_STRING_ID  mStringHelpTokenId = STRING_TOKEN (STR_UNLOADUUID_HELP_INFORMATION);

RETURN_STATUS EFIAPI AsciiStrFromGuid (
  IN  CONST GUID  *Guid,
  OUT CHAR8       *Buffer,
  IN  UINTN       BufferSize
  )
{
  if (Guid == NULL || Buffer == NULL) {
    return RETURN_INVALID_PARAMETER;
  }

  //
  // GUID string format:
  // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  // 36 characters + null terminator
  //
  if (BufferSize < 37) {
    return RETURN_BUFFER_TOO_SMALL;
  }

  AsciiSPrint(
    Buffer,
    BufferSize,
    "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
    Guid->Data1,
    Guid->Data2,
    Guid->Data3,
    Guid->Data4[0], Guid->Data4[1],
    Guid->Data4[2], Guid->Data4[3],
    Guid->Data4[4], Guid->Data4[5],
    Guid->Data4[6], Guid->Data4[7]
  );

  return RETURN_SUCCESS;
}

static void uninstall(EFI_HANDLE ImageHandle, EFI_GUID *guid) {
  EFI_STATUS Status;
  EFI_HANDLE Handle;
  UINTN Index;

  UINTN HandleCount = 0;
  EFI_HANDLE *HandleBuffer;
  VOID *Interface;

  Status = gBS->LocateHandleBuffer(ByProtocol, guid, NULL, &HandleCount, &HandleBuffer);
  ASSERT_EFI_ERROR (Status);                                                            

  for (Index = 0; Index < HandleCount; Index++) {
  	Handle = HandleBuffer[Index];

	Status = gBS->OpenProtocol(Handle, guid, &Interface, ImageHandle, NULL, EFI_OPEN_PROTOCOL_GET_PROTOCOL);
	ASSERT_EFI_ERROR (Status);
	if (EFI_ERROR(Status)) {
		Print(L"Could not OpenProtocol %u: %r\n", Index, Status);
		continue;
	}

  	Status = gBS->UninstallProtocolInterface(Handle, guid, Interface);
  	ASSERT_EFI_ERROR (Status);
  }

  if (HandleBuffer != NULL) {
	  gBS->FreePool(HandleBuffer);
  }
}

EFI_STATUS EFIAPI
UefiMain (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  uninstall(ImageHandle, &gEfiFormBrowser2ProtocolGuid);
  uninstall(ImageHandle, &gEdkiiFormBrowserExProtocolGuid);
  uninstall(ImageHandle, &gEfiHiiPopupProtocolGuid);
  uninstall(ImageHandle, &gEdkiiFormDisplayEngineProtocolGuid);

  return EFI_SUCCESS;
}
