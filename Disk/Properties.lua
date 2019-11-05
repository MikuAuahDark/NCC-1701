local ffi = require("ffi")
local Shell32 = ffi.load("Shell32")
local t

ffi.cdef[[
typedef struct _SHELLEXECUTEINFOA {
  uint32_t cbSize;
  uint32_t fMask;
  void *hwnd;
  const char *lpVerb;
  const char *lpFile;
  const char *lpParameters;
  const char *lpDirectory;
  int nShow;
  void *hInstApp;
  void *lpIDList;
  const char *lpClass;
  void *hkeyClass;
  uint32_t dwHotKey;
  union {
    void *hIcon;
    void *hMonitor;
  } DUMMYUNIONNAME;
  void *hProcess;
} SHELLEXECUTEINFOA, *LPSHELLEXECUTEINFOA;
int __stdcall ShellExecuteExA(SHELLEXECUTEINFOA *pExecInfo);
]]

function Initialize()
	t = ffi.new("SHELLEXECUTEINFOA")
	t.cbSize = ffi.sizeof("SHELLEXECUTEINFOA")
	t.nShow = 5
	t.fMask = 0xc
	t.lpVerb = "properties"
end

function Update()
	return 0
end

function ShowDiskProperties(letter)
	local diskPath = letter..":\\"

	do
		t.lpFile=diskPath
		print("Attempt open", diskPath)
		if Shell32.ShellExecuteExA(t) == 0 then
			print("ShellExecuteExA failed")
		end
	end
end
