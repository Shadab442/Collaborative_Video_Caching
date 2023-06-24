function [c,x,r] = cca(P,S,d,D,C)

K = length(P); % Number of Views
N = length(C); % Number of SBS
r = d/(D*N-d*(N-1)); % Break Point Ratio

c = zeros(N,K); % Caching Decision

% Stage 1 : Greedy Caching

[W,k] = sort(P./S,'descend'); % Weight of views

for i = 1:N
    Ctemp  = C(i);
    j = 1;
    while Ctemp > 0 && j <=K  
        if Ctemp > S(k(j))
            Ctemp = Ctemp - S(k(j));
            c(i,k(j)) = 1;
            j = j+1;
        else
            break;
        end
    end
end
% c

% Stage 2 : Compare and Replacement 

k2 = j;

for i = 1: N-1
    k1 = j-1;
    Ctempi = Ctemp;
    flag = 0;
    while k1 > 0 && k2 <= K     
        Ctempt = Ctempi;
        Wt = 0;
        kt = k1 + 1;
        while Ctempt < S(k(k2)) 
            kt = kt - 1;
            if kt == 0
                flag = 1;
                break
            end
            Ctempt = Ctempt + S(k(kt));
            Wt = Wt + W(kt);
            if  W(k2)/Wt < r 
                flag = 1;
                break
            end
        end
        if flag == 1 && kt == k1
            break
        end
      
        if flag == 0 
            Ctempi = Ctempi - S(k(k2));
            if kt <= k1 
                for m = k1 : -1: kt
                    c(i,k(m)) = 0;
                    Ctempi = Ctempi + S(k(k1));
                    k1 =  k1 - 1; 
                end
            end
            c(i,k(k2)) = 1;
        end
        k2 =  k2 + 1;
    end
    c = residual_space_fill(S,Ctempi,i,c); 
end

% Stage 3: Rounding

c = residual_space_fill(S,Ctempi,N,c);

% c

n = sum(vec2mat(c,K));
r = n==0;
cv= reshape(c,[],1);
x =[cv; r'];

end

function c = residual_space_fill(S,Ctempi,i,c)

kp = find (S<=Ctempi);

if ~isempty(kp)
    for l = 1:length(kp)
        if Ctempi > S(kp(l)) && sum(c(:,kp(l))) == 0
            Ctempi = Ctempi - S(kp(l));
            c(i,kp(l)) = 1;
        end
    end
    if Ctempi > 0
        for l = 1:length(kp)
            if Ctempi > S(kp(l)) && sum(c(i,kp(l))) == 0
                Ctempi = Ctempi - S(kp(l));
                c(i,kp(l)) = 1;
            end
        end
    end
end
    
end