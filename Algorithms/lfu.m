function c = lfu(r1,S,C)

% sort as per frequency 

c = zeros(1,length(r1));
[s,k] = sort(r1,'descend');

Ctemp = C;
j = 1;

% Cache greedily as per the sorted order

while Ctemp > 0 && j < length(r1)
    if Ctemp > S(k(j))
        Ctemp = Ctemp - S(k(j)); 
        c(k(j)) = 1; 
        j = j + 1; 
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