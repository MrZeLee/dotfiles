local function isNixos()
	local handle = io.popen("test -d /etc/nixos && echo true || echo false")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return result:match("true") ~= nil
	end
	return false
end

local function isDarwin()
    local handle = io.popen("uname")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:match("Darwin") ~= nil
  end
  return false
end

IsNixos = isNixos();
IsDarwin = isDarwin();
