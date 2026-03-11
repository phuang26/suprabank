::GitBranch = begin
  File.open("#{Rails.root}/gitbranch", &:readline)
rescue Errno::ENOENT
  "unknown"
end
