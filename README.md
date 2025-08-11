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
