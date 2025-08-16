module OliveMarkdown
import Olive: olive_save, Project, Cell, build, olive_read
import Olive.IPyCells: AbstractCell
using Olive: Connection, Directory, style!, build_base_cell, ProjectExport, Component

function make_cellstr(cell::Cell{<:Any}, celltype::Any)
    cellstr::String = """\n```$celltype
    $(cell.source)
    ```"""
    if ~(isnothing(cell.outputs)) && cell.outputs != ""
        cellstr = cellstr * "\n```output\n$(cell.outputs)\n```\n"
    end
    return(cellstr)::String
end

olivemd_string(cell::Cell{<:Any}) = begin
    celltype = typeof(cell).parameters[1]
    return(make_cellstr(cell, celltype))::String
end

function olivemd_string(cell::Cell{:markdown})
    cell.source::String
end

function olivemd_string(cell::Cell{:mdro})
    cell.source::String
end

function olivemd_string(cell::Cell{:code})
    make_cellstr(cell, "julia")::String
end

function olivemd_string(cell::Cell{:codero})
    make_cellstr(cell, "julia")::String
end

function olivemd_string(cell::Cell{:tomlvalues})
    make_cellstr(cell, "toml")
end

function imagecell_omd_str(cell::Cell{<:Any})
    fmt = lowercase(cell.source)
    outpimg = base64img("cell$(cell.id)", cell.outputs[2], fmt)
    b64 = replace(outpimg[:src], "data:image/$fmt;base64," => "")
    """```imgb64
    $(cell.source)!|$(cell.outputs[1])!|$(b64)!|$(cell.outputs[3])!|$(cell.outputs[4])
    ```
    """
end

function olivemd_string(cell::Cell{:image})
    imagecell_omd_str(cell)
end

function olivemd_string(cell::Cell{:vimage})
    make_cellstr(cell, "svg")
end

function olivemd_string(cell::Cell{:imagero})
    imagecell_omd_str(cell)
end

function olivemd_string(cell::Cell{:vimagero})
    make_cellstr(cell, "svg")
end

function olivemd_save(cells::Vector{Cell}, path::AbstractString; mdcellt::Type = Cell{:markdown})
    if ~(isfile(path))
        touch(path)
    end
    open(path, "w") do o::IOStream
        n = length(cells)
        for e in 1:n
            cell = cells[e]
            cell_str = olivemd_string(cell)
            if typeof(cell) == mdcellt && e != n && typeof(cells[e + 1]) == mdcellt
                if cell_str[end] != '\n'
                    cell_str = cell_str * "\n"
                end
            end
            write(o, cell_str)
        end
    end
end

function construct_mdcell(type::Type{<:AbstractCell}, source::String, outputs::Any = nothing)
    type(source, outputs)
end

function construct_mdcell(type::Type{Cell{:julia}}, source::String, outputs::Any = nothing)
    Cell{:code}(source, outputs)
end

function construct_mdcell(type::Type{Cell{:toml}}, source::String, outputs::Any = nothing)
    Cell{:tomlvalues}(source, outputs)
end

function construct_mdcell(type::Type{Cell{:svg}}, source::String, outputs::Any = nothing)
    Cell{:vimage}(source, outputs)
end

function construct_mdcell(type::Type{Cell{:imgb64}}, source::String, outputs::Any = nothing)
    splts = split(cell.source, "!|")
    Cell{:image}(replace(splits[1], " " => "", "\n" => ""), join(splts[2:end], "!|"))
end

function olive_save(p::Project{<:Any}, pe::ProjectExport{:md})
    olivemd_save(p[:cells], p[:path])
end

function parse_omd_cell(raw::AbstractString)
    code_found = findfirst("``", raw)
    if code_found == 1:2
        nextend = findfirst("\n", raw)
        if isnothing(nextend)
            nextend = findfirst(" ", raw)
            @warn raw
            if isnothing(nextend)
                nextend = length(raw)
            end
        end
        celltend = minimum(nextend)
        cellt = replace(raw[begin:celltend], "`" => "", " " => "", "\n" => "")
        if cellt == "output"
            return(raw[celltend + 1:end])
        end
        cell = construct_mdcell(Cell{Symbol(cellt)}, raw[celltend + 1:end])
        return(cell)
    end
    return(Cell{:markdown}(raw))
end

is_invalid_cellstr(str::AbstractString) = begin
    badvalues = ('\n', ' ', '`')
    isnothing(findfirst(x -> ~(x in badvalues), str))
end

function read_olivemd(path::String)
    cells = Vector{Cell}()
    position::Int64 = 1
    raw::String = read(path, String)
    while true
        next_block = findnext("```", raw, position)
        next_nn = findnext("\n\n", raw, position)
        no_nn = isnothing(next_nn)
        no_block = isnothing(next_block)
        selected_upper = if no_block && no_nn
            nothing
        elseif no_block
            next_nn
        elseif no_nn
            next_block
        else
            mins = (minimum(next_nn), minimum(next_block))
            if findmin(mins) == 1
                next_nn
            else
                next_block
            end
        end
        if isnothing(selected_upper)
            # add last md cell, break loop
            final_str = raw[position:end]
            if is_invalid_cellstr(final_str)
                break
            end
            cell = parse_omd_cell(final_str)
            if typeof(cell) <: AbstractString
                cells[end].outputs = cell
            else
                push!(cells, cell)
            end
            break
        end
        n = length(selected_upper)
        selected_upper = minimum(selected_upper)
        selected_str = raw[position:selected_upper - 1]
        if is_invalid_cellstr(selected_str)
            position = selected_upper + 1
            continue
        end
        cell = parse_omd_cell(selected_str)
        if typeof(cell) <: AbstractString
            cells[end].outputs = cell
        else
            push!(cells, cell)
        end
        position = selected_upper + 1
    end
    return(cells)::Vector{Cell}
end

function build(c::Connection, cell::Cell{:md},
    d::Directory)
    cell_component::Component{:div} = build_base_cell(c, cell, d)
    style!(cell_component, "background-color" => "#5d6675")
    cell_component
end

function olive_read(cell::Cell{:md})::Vector{Cell}
    read_olivemd(cell.outputs)
end

end # module OliveMarkdown
