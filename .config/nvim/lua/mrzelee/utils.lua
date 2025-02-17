function IsNixos()
	local handle = io.popen("test -d /etc/nixos && echo true || echo false")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return result:match("true") ~= nil
	end
	return false
end
