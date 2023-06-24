clc
close all
clear all

% This files needs IBM ILOG CPLEX OPTIMIZATION V12.8 to run as it uses
% "cplexbilp" function inside the "opt" function. If the optimization
% toolbox is not installed, cplex_enabled should be put as 0.

cplex_enabled = 0; % Flag for whether CPLEX is enabled or not
                   % O if not enabled, 1 if enabled.

% Two different "Dataset" options: Choose either "Youtube" or "Netflix"

Dataset = "Netflix";

% Loading data for all the videos in the dataset

if strcmp (Dataset,"Youtube")
    filename = "Youtube_video_statistics.mat";
else
    filename = "Netflix_video_statistics.mat";
end

o = load(filename);

P = o.P; % Popularity vector
S = o.S; % Video size vector

% Choose a limited number of videos because optimizers take a long time to
% run for a large number of videos

n = 20; % Number of videos to consider

P = (P(1:n)/sum(P(1:n))); % Popularity vector for n videos
S = S(1:n); % Video size vector for n videos

% System parameters

d = 500*10^-3; % Local Delay
D = [2500 5000]*10^-3; % Remote Delay

if cplex_enabled == 1
    line = {'-xb', '--xb', '-or', '--or'};
end

%% Average delay variation with cache space with fixed number of SBSs 

if strcmp(Dataset,"Youtube")
    Cs = 50:20:250; % Cache space in MB
    N = 4; % Number of SBSs
    C = 10^6*ones(1,N);% 1 MB Cache size 
else
    Cs = 5:5:50; % Cache space in GB
    N = 6; % Number of SBSs
    C = 10^9*ones(1,N); % 1 GB Cache size
end

tic
for j = 1:length(D)
    dc = zeros(length(Cs),1);
    da = dc;
    for i = 1:length(Cs)
        i
        [cc,xc,yc] = cca(P,S,d,D(j),Cs(i)*C); % CCA solution
        nc = sum(cc);
        dc(i)  = d*sum(P) - d*(P*nc')/N + (D(j)-d)*(P*yc'); % Average delay 
                                                            % from CCA

        if cplex_enabled == 1
            [f,ca,xa,ya] = opt (P,S,d,D(j),Cs(i)*C); % Optimal solution
            na = sum(ca); 
            da(i)  = d*sum(P) - d*(P*na')/N + (D(j)-d)*(P*ya');% Average delay 
                                                            % from optimal
        end
    end

    if cplex_enabled == 0

        plot(Cs,dc,'Linewidth',2)
        hold on;

    else 
        plot(Cs,dc,line{j*2-1},'Linewidth',2)
        hold on;
        plot(Cs,da,line{j*2},'Linewidth',2)
        hold on;
    end
end

grid on;

if strcmp(Dataset,"Youtube")
    xlabel('Cache Space (MB)')
else
    xlabel('Cache Space (GB)')
end

ylabel('Average Delay (s)')

if cplex_enabled == 1
    legend('D = 2.5 s : CCA', 'D = 2.5 s : OPT', 'D = 5 s : CCA', 'D = 5 s : OPT')
else
    legend('D = 2.5 s : CCA', 'D = 5 s : CCA')
end

toc

%% Average delay variation with number of SBSs with fixed cache space

if strcmp(Dataset,"Youtube")
    Cs = 20;
else
    Cs = 25;
end

N = 2:2:8;

if cplex_enabled == 1
    a_d  = zeros (length(N),2*length(D));
else
    a_d  = zeros (length(N),length(D));
end

for j = 1:length(D)
    dc = zeros(length(N),1);
    da = dc;
    for i = 1:length(N)   
        i
        C = 10^9*ones (1,N(i));
        [cc,xc,yc] = cca(P,S,d,D(j),Cs*C);
        nc = sum(cc);
        dc(i)  = d*sum(P) - d*(P*nc')/N(i) + (D(j)-d)*(P*yc');

        if cplex_enabled == 1
            [f,ca,xa,ya] = opt(P,S,d,D(j),Cs*C);
            na = sum(ca);
            da(i)  = d*sum(P) - d*(P*na')/N(i) + (D(j)-d)*(P*ya');
        end
    end

    if cplex_enabled == 1
        a_d(:,2*j - 1 ) = dc;
        a_d(:,2*j ) = da;
    else
        a_d(:,j ) = dc;
    end
end

figure;
bar(N,a_d)
grid on;
xlabel('Number of SBSs')
ylabel('Average Delay (s)')

if cplex_enabled == 1
    legend('D = 2.5 s : CCA', 'D = 2.5 s : OPT', 'D = 5 s : CCA', 'D = 5 s : OPT')
else
    legend('D = 2.5 s : CCA', 'D = 5 s : CCA')
end