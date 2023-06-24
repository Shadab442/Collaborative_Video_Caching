function c = lru(r2,S,C)

c = zeros(1,length(S));

Ctemp = C;
j = 1;

% Cache greedily as per the recency order

while Ctemp > 0 && j < length(r2)
    if Ctemp > S(r2(j))
        Ctemp = Ctemp - S(r2(j)); 
        c(r2(j)) = 1; 
        j = j+1; 
    else
        j = j + 1; 
    end
end

% Residual filling

kp = find (S<=Ctemp);

for l = 1:length(kp)
    if Ctemp > S(kp(l)) && c(kp(l)) == 0
        Ctemp = Ctemp - S(kp(l));
        c(kp(l)) = 1;
    end
end