extends Node

const STANDALONE_ROOT := "res://"

var root_path := STANDALONE_ROOT
var embedded := false
var host_api


func configure_for_embedded(api) -> void:
	embedded = true
	host_api = api
	root_path = api.module_root


func path(relative_path: String) -> String:
	if relative_path.begins_with("res://") or relative_path.begins_with("user://"):
		return relative_path
	return "%s/%s" % [root_path.trim_suffix("/"), relative_path.trim_prefix("/")]


func request_exit() -> void:
	if embedded and host_api:
		host_api.request_exit()
