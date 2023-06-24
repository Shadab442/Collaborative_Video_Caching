function c = cca_greedy(r,S,C)

% clc 
% close all
% clear all

% P = [0.6 0.095 0.09 0.06 0.027 0.083 0.036 0.005 0.001 0.003]; % Popularity of views
% S = [10 8 6 8 6 5 5 7 2 3]; % Size of Views
% Data = table2cell(readtable('PV.xlsx','Sheet',2));
% P = cell2mat(Data(:,2));
% P = (P/sum(P))';
% S = (cell2mat(Data(:,3)))';
% 
% d = 10^-3; % Local Delay
% D = 1.5*10^-3; % Remote Delay
% C = 50*10^6* ones (1,4); % Cache Size

K = length(r); % Number of Views
%N = length(C); % Number of SBS
%r = d/(D*N-d*(N-1)); % Break Point Ratio
P = r/sum(r);

c = zeros(1,K); % Caching Decision

% Stage 1 : Greedy Caching

[W,k] = sort(P./S,'descend'); % Weight of views

Ctemp  = C;
j = 1;

while Ctemp > 0 && j <=K  
    if Ctemp > S(k(j))
        Ctemp = Ctemp - S(k(j));
        c(k(j)) = 1;
        j = j+1;
    else
        break;
    end
end

kp = find (S<=Ctemp);

for l = 1:length(kp)
    if Ctemp > S(kp(l)) && c(kp(l)) == 0
        Ctemp = Ctemp - S(kp(l));
        c(kp(l)) = 1;
    end
end
% c

% Stage 3 : Replacement 

% k2 = j;
% 
% for i = 1: N-1
%     k1 = j-1;
%     Ctempi = Ctemp;
%     flag = 0;
%     while k1 > 0 && k2 <= K     
%         Ctempt = Ctempi;
%         Wt = 0;
%         kt = k1 + 1;
%         while Ctempt < S(k(k2)) 
%             kt = kt - 1;
%             if kt == 0
%                 flag = 1;
%                 break
%             end
%             Ctempt = Ctempt + S(k(kt));
%             Wt = Wt + W(kt);
%             if  W(k2)/Wt < r 
%                 flag = 1;
%                 break
%             end
%         end
%         if flag == 1 && kt == k1
%             break
%         end
%       
%         if flag == 0 
%             Ctempi = Ctempi - S(k(k2));
%             if kt <= k1 
%                 for m = k1 : -1: kt
%                     c(i,k(m)) = 0;
%                     Ctempi = Ctempi + S(k(k1));
%                     k1 =  k1 - 1; 
%                 end
%             end
%             c(i,k(k2)) = 1;
%         end
%         k2 =  k2 + 1;
%     end
%     c = residual_space_fill(S,Ctempi,i,c); 
% end
% 
% c = residual_space_fill(S,Ctemp,N,c);
% 
% % c
% 
% n = sum(vec2mat(c,K));
% r = n==0;
% cv= reshape(c,[],1);
% x =[cv; r'];
% 
% end
% 
% function c = residual_space_fill(S,Ctempi,i,c)
% 
% 
% 
% if ~isempty(kp)
%     for l = 1:length(kp)
%         if Ctempi > S(kp(l)) && sum(c(:,kp(l))) == 0
%             Ctempi = Ctempi - S(kp(l));
%             c(i,kp(l)) = 1;
%         end
%     end
%     if Ctempi > 0
%         for l = 1:length(kp)
%             if Ctempi > S(kp(l)) && sum(c(i,kp(l))) == 0
%                 Ctempi = Ctempi - S(kp(l));
%                 c(i,kp(l)) = 1;
%             end
%         end
%     end
% end
%     
% end