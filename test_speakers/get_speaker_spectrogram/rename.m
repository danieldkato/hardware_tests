function out = rename(in)
    replace = {{' ','_'}
                {'"','-inch'}
                {'/','fwslash'}
        };
    out = in;
    for i =1:length(replace)
         out = strrep(out, replace{i}{1}, replace{i}{2});
    end
    