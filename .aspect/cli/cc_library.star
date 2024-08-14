aspect.register_rule_kind("cc_library", {
    "From": "@rules_cc//cc:defs.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})

def declare(ctx):
    for file in ctx.sources:
        deps = []
        for imp in file.query_results["imports"]:
            id = imp.captures["import"]
            if id == "gtest/gtest":
                deps.append("@googletest//:gtest_main")
            elif id == "sqlite3":
                deps.append("@sqlite3")
            else:
                deps.append(aspect.Import(
                    id = id,
                    provider = "cc",
                    src = file.path,
                ))
        ctx.targets.add(
            name = file.path[:file.path.rindex(".")] + "_lib",
            kind = "cc_library",
            attrs = {
                "srcs": [file.path],
                # FIXME:
                # "hdrs": [file.path.replace(".cc", ".h")],
                "deps": deps,
            },
            symbols = [aspect.Symbol(
                id = "/".join([ctx.rel, file.path.removesuffix(".cc")]) if ctx.rel else file.path.removesuffix(".cc"),
                provider = "cc",
            )],
        )

aspect.register_configure_extension(
    id = "cpp",
    prepare = lambda _: aspect.PrepareResult(
        sources = [aspect.SourceExtensions(".cc")],
        queries = {
            # TODO: use treesitter C++ once it's built into Aspect CLI
            "imports": aspect.RegexQuery(
                filter = "*.cc",
                expression = """#include\\s+"(?P<import>[^.]+).h\""""
            ),
        },
    ),
    declare = declare,
)
