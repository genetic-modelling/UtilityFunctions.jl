using UtilityFunctions
using Documenter

DocMeta.setdocmeta!(UtilityFunctions, :DocTestSetup, :(using UtilityFunctions); recursive=true)

makedocs(;
    modules=[UtilityFunctions],
    authors="Jonathan Miller jonathan.miller@fieldofnodes.com",
    sitename="UtilityFunctions.jl",
    format=Documenter.HTML(;
        canonical="https://fieldofnodes.github.io/UtilityFunctions.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/UtilityFunctions.jl",
    devbranch="main",
)
