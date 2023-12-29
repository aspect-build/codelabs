"TODO"
load("@aspect_bazel_lib//lib:run_binary.bzl", "run_binary")

def myorg_py_header(name, tmpl, out, **kwargs):
    run_binary(
        name = name,
        outs = [out],
        srcs = [
            tmpl,
            "//tools:data.json",
        ],
        # The tool to run in the action
        tool = "//tools:jinja2",
        args = ["--format=json", "-o", "$(execpath %s)" % out, "$(execpath %s)" % tmpl, "$(execpath //tools:data.json)"],
        **kwargs,
    )
