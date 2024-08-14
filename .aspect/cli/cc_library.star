aspect.register_rule_kind("cc_library", {
    "From": "@rules_cc//cc:defs.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})

def prepare(_):
    return aspect.PrepareResult(
        sources = [
            aspect.SourceExtensions(".cc"),
        ],
        queries = {
            # TODO: use treesitter C++ once it's built into Aspect CLI
            "imports": aspect.RegexQuery(
                filter = "*.cc",
                expression = """#include\\s+"(?P<import>[^.]+).h\""""
                # import\\s+"(?P<import>[^"]+)\",
            ),
        },
    )

def declare(ctx):
    for file in ctx.sources:
        ctx.targets.add(
            name = file.path[:file.path.rindex(".")] + "_lib",
            kind = "cc_library",
            attrs = {
                "srcs": [file.path],
                "deps": [
                    aspect.Import(
                        id = i.captures["import"],
                        provider = "cc",
                        src = file.path,
                    )
                    for i in file.query_results["imports"]
                ],
            },
            symbols = [aspect.Symbol(
                id = "/".join([ctx.rel, file.path.removesuffix(".cc")]) if ctx.rel else file.path.removesuffix(".cc"),
                provider = "cc",
            )],
        )

aspect.register_configure_extension(
    id = "cpp-regex",
    prepare = prepare,
    declare = declare,
)
