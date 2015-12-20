function charV = num2strR(v)
charV = zeros(1,length(v));
for i = 1:length(v)
    if v(i) == 0
        charV(i) = 0;
    elseif v(i)<=10
        charV(i) = v(i) + 48 -1;
    elseif v(i)<=36
        charV(i) = v(i) +65 - 11;
    else
        charV(i) = v(i) +97 - 37;
    end
end
charV = char(charV);
end