<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/0.1/extensions/olivemarkdown.png" width="190"></img>
</div>

`OliveMarkdown` provides [Olive](https://github.com/ChifiSource/Olive.jl) with the ability to read and save markdown (`.md`) files from regular `Olive` cells.

- Regular `Olive` output:
```julia
"""# Toolips Components
`Toolips` Components are composable, let's take a look at some code which demonstrates how to use these Components!
"""
#==|||==#
using Toolips
#==output[code]

==#
#==|||==#
```
- `OliveMarkdown` export output:
```markdown
# Toolips Components
`Toolips` Components are composable, let's take a look at some code which demonstrates how to use these Components!
```julia
using Toolips
```julia
```output
Nothing
```output
```
### adding
To add `OliveMarkdown`, either load it before starting `Olive` or add `OliveMarkdown` to your `olive` home. To learn more, check out [installing extensions](https://chifidocs.com/olive/Olive/installing-extensions).
```julia
using Pkg

Pkg.add("OliveMarkdown")

# unstable?
Pkg.add("OliveMarkdown", rev = "Unstable")
```
```julia
# start headless example:
using OliveMarkdown; using Olive; Olive.start(headless = true)
```
