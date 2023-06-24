function [f,c,x,r] = opt (P,S,d,D,C)

N = length(C); % Number of SBS
K = length(P); % Number of views

Ar = [kron(ones(1,N),eye(K)) N*eye(K)];
Ac = [kron(eye(N),S) zeros(N,K)];
Aineq = [Ar; -Ar; Ac];

bineq  = [N*ones(K,1); -ones(K,1); C'];

f = [repmat((-P*d),1,N)/N (D-d)*P];

lb = zeros((N+1)*K,1);
ub = ones((N+1)*K,1);

x = cplexbilp(f,Aineq,bineq,[],[],lb,ub);
c = vec2mat(x(1:N*K),K);

n = sum(vec2mat(c,K));
r = n==0;
