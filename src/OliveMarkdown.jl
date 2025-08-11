module OliveMarkdown
import Olive: olive_save, Project, ProjectExport, Cell

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

function olivemd_string(cell::Cell{:code})
    make_cellstr(cell, "julia")::String
end

function olivemd_string(cell::Cell{:tomlvalues})
    make_cellstr(cell, "toml")
end

function olivemd_save(cells::Vector{Cell}, path::AbstractString; mdcellt::Type = Cell{:markdown})
    if ~(isfile(path))
        touch(path)
    end
    open(path, "w") do o::IOStream
        for e in 1:length(cells)
            cell = cells[e]
            cell_str = olivemd_string(cell)
            if typeof(cell) == mdcellt && typeof(cells[e + 1]) == mdcellt
                if cell_str[end] == '\n'
                    cell_str = cell_str * "\n"
                else
                    cell_str = cell_str * "\n\n"
                end
            end
            write(o, cell_str)
        end
    end
end

function olive_save(p::Project{<:Any}, pe::ProjectExport{:md})
#    IPyCells.save(p.data[:cells], p.data[:path])
end

end # module OliveMarkdown
