for i = 218:249
    disp(i)
    if ~sum(i==[206 217 222 226])
        Classify_character(i);
    end
end