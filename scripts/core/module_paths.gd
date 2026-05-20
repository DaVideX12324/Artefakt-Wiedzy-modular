extends RefCounted
class_name ModulePaths

static func join(root_path: String, relative_path: String) -> String:
	if relative_path.begins_with("res://") or relative_path.begins_with("user://"):
		return relative_path
	return "%s/%s" % [root_path, relative_path.trim_prefix("/")]
