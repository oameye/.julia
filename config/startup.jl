if Base.isinteractive() && (local REPL = get(Base.loaded_modules, Base.PkgId(Base.UUID("3fa0cd96-eef1-5676-8a61-b3b8758bbffb"), "REPL"), nothing); REPL !== nothing)

    # Setup OhMyREPL and Revise
    import Pkg
    let
        pkgs = ["Revise", "OhMyREPL", "JuliaSyntax", "BasicAutoloads"]
        for pkg in pkgs
            if Base.find_package(pkg) === nothing
                Pkg.add(pkg)
            end
        end
    end

    atreplinit() do repl
    @eval begin
        import JuliaSyntax
        JuliaSyntax.enable_in_core!(true)
    end
end

    atreplinit() do repl
        try
            @eval (using OhMyREPL; colorscheme!("Monokai16"))
            @eval using Revise
            @eval begin
                import JuliaSyntax
                JuliaSyntax.enable_in_core!(true)
            end
        catch e
            @warn "error while importing OhMyREPL or Revise" e
        end
    end

    if isinteractive()
        import BasicAutoloads
        BasicAutoloads.register_autoloads([
            ["@b", "@be"]            => :(using Chairmarks),
            ["@benchmark"]           => :(using BenchmarkTools),
            ["@test", "@testset", "@test_broken", "@test_deprecated", "@test_logs",
            "@test_nowarn", "@test_skip", "@test_throws", "@test_warn", "@inferred"] =>
                                        :(using Test),
            ["@about"]               => :(using About; macro about(x) Expr(:call, About.about, x) end),
        ])
    end

 end
