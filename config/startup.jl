if Base.isinteractive() && (local REPL = get(Base.loaded_modules, Base.PkgId(Base.UUID("3fa0cd96-eef1-5676-8a61-b3b8758bbffb"), "REPL"), nothing); REPL !== nothing)

    # Setup OhMyREPL and Revise
    import Pkg
    let
        pkgs = ["Revise", "OhMyREPL"]
        for pkg in pkgs
            if Base.find_package(pkg) === nothing
                Pkg.add(pkg)
            end
        end
    end

    atreplinit() do repl
        try
            @eval (using OhMyREPL; colorscheme!("Monokai16"))
            @eval using Revise
        catch e
            @warn "error while importing OhMyREPL or Revise" e
        end
    end

    # Automatically load tooling on demand:
    # - BenchmarkTools.jl when encountering @btime or @benchmark
    # - Cthulhu.jl when encountering @descend(_code_(typed|warntype))
    # - Debugger.jl when encountering @enter or @run
    # - Profile.jl when encountering @profile
    # - ProfileView.jl when encountering @profview
    local tooling_dict = Dict{Symbol,Vector{Symbol}}(
        :BenchmarkTools => Symbol.(["@btime", "@benchmark"]),
        # :Debugger       => Symbol.(["@enter", "@run"]),
        # :Profile        => Symbol.(["@profile"]),
        # :ProfileView    => Symbol.(["@profview"]),
    )
    pushfirst!(REPL.repl_ast_transforms,
        function(ast::Union{Expr,Nothing})
            function contains_macro(ast, m)
                return ast isa Expr && (
                    (Meta.isexpr(ast, :macrocall) && ast.args[1] === m) ||
                    any(x -> contains_macro(x, m), ast.args)
                )
            end
            for (mod, macros) in tooling_dict
                if any(contains_macro(ast, s) for s in macros) && !isdefined(Main, mod)
                    @info "Loading $mod ..."
                    try
                        Core.eval(Main, :(using $mod))
                    catch err
                        @info "Failed to automatically load $mod" exception=err
                    end
                end
            end
            return ast
        end
    )

 end
