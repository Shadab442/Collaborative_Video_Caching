function [a_rtb,a_ltb,a_rfb,a_lfb,a_dc] = dynamic_optimization(Dataset,type,quality, req, d,D,C,w_l,alpha)

N = length(C); % number of SBSs
i = 1; % index of current request

% Different dynamic performance characteristics during time evolution

Rtb = []; % remote delivery bytes during each window
Ltb = []; % local delivery bytes during each window
Rfb = []; % remote reoptimization bytes after each window
Lfb = []; % local reoptimization bytes after each window
Ch  = []; % Cache hits during each window
Cm  = []; % Cache misses during each window
Dc  = []; % Average delay incurred during each window

% Moving average of different dynamic performance characteristics during time evolution

Rtbm = []; 
Ltbm = []; 
Rfbm = []; 
Lfbm =[];  
Chm = []; 
Cmm = []; 
Dcm = [];

c   = []; % cache placement matrix
V   = []; % initial online library of videos
P   = []; % initial online updated popularity vector
n_0 = []; % initial number of cached copies
S   = []; % initial online updated size vector

% To ensure d or D does not change at each request

d_fixed = d;
D_fixed = D;

if strcmp(type, 'Comparison')
    % 1 for LFU
    % 2 for LRU
    % 3 for CCA-Greedy

    r1 = []; % Frequency Vector
    r2 = {}; % Recency Matrix

    Dc1  = [];
    Rtb1 = []; 
    Rfb1 = []; 
    Ch1  = []; 
    Cm1  = []; 
    Ltb1 = [];
    Lfb1 = [];

    Rtb2 = []; 
    Rfb2 = []; 
    Ch2  = []; 
    Cm2  = []; 
    Dc2  = [];
    Ltb2 = [];
    Lfb2 = [];

    Rtb3 = []; 
    Rfb3 = []; 
    Ch3  = []; 
    Cm3  = []; 
    Dc3  = []; 

    Chm1  = []; 
    Cmm1  = []; 
    Dcm1  = [];
    Rfbm1 = [];
    Rtbm1 = [];
    Ltbm1 = [];
    Lfbm1 = [];

    Chm2  = []; 
    Cmm2  = []; 
    Dcm2  = [];
    Rfbm2 = [];
    Rtbm2 = [];
    Ltbm2 = [];
    Lfbm2 = [];

    Rtbm3 = []; 
    Rfbm3 = []; 
    Chm3  = []; 
    Cmm3  = []; 
    Dcm3  = []; 

    c1 = [];
    c2 = [];
    c3 = [];

    n_01 = []; 
    n_02 = []; 
    n_03 = []; 
end
    


while i <= size(req,1)
    i % Request index
    
    % Initialization of Different dynamic performance characteristics for
    % each window
    
    r   = zeros(size(P)); % calculation of requests at each window
    ch  = 0; 
    cm  = 0; 
    rtb = 0; 
    ltb = 0; 
    rfb = 0; 
    lfb = 0; 
    dc  = 0;

    if strcmp(type, 'Comparison')
        ch1  = 0; 
        cm1  = 0;
        rtb1 = 0; 
        rfb1 = 0; 
        ltb1 = 0;
        lfb1 = 0;
        dc1  = 0;

        ch2  = 0; 
        cm2  = 0; 
        rtb2 = 0; 
        rfb2 = 0; 
        ltb2 = 0;
        lfb2 = 0;
        dc2  = 0;

        ch3  = 0; 
        cm3  = 0; 
        rtb3 = 0; 
        rfb3 = 0; 
        dc3  = 0;
    end
    
    i2 = 1; % Valid request index in a window
    
    while i2 <= w_l && i <= size(req,1)
        
        p = req{i,2}; % Video ID of current request 
        s = req{i,3}; % Video sizeo of current request

        if strcmp(Dataset,"Youtube")
            k = req{i,4}; % SBS of current request
        else
            k = mod(req{i,4},N) + 1; % SBS of current request
        end

        % If quality is enabled, quality = 1, else default to 0

        if quality == 1
            % Assign the video quality in the video ID

            % [480p 720p 1080p]

            qp = [0.27 0.365 0.365]; % Quality rendering probability

             if strcmp(Dataset,"Youtube")
                qs = [0.4 1 2.5]; % Video size multiplication factor
            else
                qs = [0.16 0.4 1]; % Video size multiplication factor
            end
            
    
            x = rand; % For determining the quality

            % l for determining the index for video size dependning on the
            % quality
            
            % Condtion for 480p
            if x <= qp(1) 
                l = 1;
    
            % Condtion for 720p
            elseif x > qp(2) && x <= (qp(1) + qp(2))
                l = 2;
    
            % Condtion for 1080p
            else  
                l = 3;
            end
    
            p = 3 * (p - 1) + l; % New video index considering quality

            s = s * qs(l); 
            d = d_fixed * qs(l); 
            D = D_fixed * qs(l); 

        end

        % finding out the video index m from the the video library
        flag = 0; % no match found
        
        % if a cached video is requested
        for m = 1:size(V,2)
            if V(m) == p
                r(m) = r(m) + 1; % updating new video requests
                if strcmp(type, 'Comparison')
                    r1(k,m) = r1(k,m) + 1;
    
                    a = r2{k};
                    a = a(a~=m);
                    a = [m a];
                    r2{k} = a;
                end

                S(m) = max(s,S(m)); % Taking the maximum in case of variable video sizes

                flag = 1; % match found from existing video library  

                if c(k,m) ~= 1 % requested video not locally cached

                    % requested video not cached at any neighbouring SBS
                    if sum(c(:,m) ~= 1) == N 
                        rtb = rtb +  S(m); % updating remote transmission bw
                        dc  = dc + D;  % Increase average delay by remote delay
                        cm  = cm + 1;  % Cache miss increment

                    % requested video cached at any neighbouring SBS
                    else 
                        ltb = ltb + S(m); % updating local transmission bw
                        dc  = dc + d;  % Increase average delay by local delay
                        ch  = ch + 1;  % Cache hit increment
                    end

                else % requested video cached at requesting SBS
                    ch = ch + 1; % Cache hit increment
                end

                if strcmp(type, 'Comparison')
                    if c1(k,m) ~= 1 
                        if sum(c1(:,m) ~= 1) == N
                            rtb1 = rtb1 + S(m); 
                            dc1 = dc1 + D;
                            cm1 = cm1 + 1; 
                        else
                            ltb1 = ltb1 + S(m); 
                            dc1 = dc1 + d;
                            ch1 = ch1 + 1;
                        end
                    else 
                        ch1 = ch1 + 1; 
                    end
    
                    if c2(k,m) ~= 1
                        if sum(c2(:,m) ~= 1) == N
                            rtb2 = rtb2 + S(m); 
                            dc2 = dc2 + D;
                            cm2 = cm2 + 1; 
                        else
                            ltb2 = ltb2 + S(m); 
                            dc2 = dc2 + d;
                            ch2 = ch2 + 1;
                        end
                    else 
                        ch2 = ch2 + 1; 
                    end
    
                    if c3(k,m) ~= 1 
                        rtb3 = rtb3 + S(m);
                        dc3 = dc3 + D;
                        cm3 = cm3 + 1; 
                    else
                        ch3 = ch3 + 1;
                    end   
                end
                
                break;
            end
        end
        
        % if an uncached video is requested
        if flag == 0                
            V = [V p]; % updating online video library
            S =[S s]; % updating online video size library

            ct = zeros(N,1);
            c = [c ct]; % updating new cache spaces
            r = [r 1]; % updating new video requests

            rtb = rtb + s; % updating remote transmission bw
            dc = dc + D; % Increase average delay by remote delay
            cm = cm + 1; % Cache miss increment

            if strcmp(type, 'Comparison')

                c3 = [c3 ct]; 
                rtb3 = rtb3 + s; 
                dc3 = dc3 + D;
                cm3 = cm3 + 1; 
    
                c1 = [c1 ct];
                ct(k) = 1;
                r1 = [r1 ct];
                rtb1 = rtb1 + s; 
                dc1 = dc1 + D;
                cm1 = cm1 + 1; 
    
                c2 = [c2 ct];
                if ~isempty(r2)
                    r2{k} = [length(S) r2{k}];  
                else
                    r2{k} = length(S);
                end
                rtb2 = rtb2 + s; 
                dc2 = dc2 + D;
                cm2 = cm2 + 1;   
            end
        end 
        
        i2 = i2 + 1; % Increment request index in each window
        i = i + 1; % Increment request index
    end
    
    if length(r)- length(P) > 0
        n_0 = [n_0 1 zeros(1,(length(r) - length(P)-1))]; % updating n_0
        if strcmp(type, 'Comparison')
            n_01 = [n_01 1 zeros(1,(length(r) - length(P)-1))];
            n_02 = [n_02 1 zeros(1,(length(r) - length(P)-1))];
            n_03 = [n_03 1 zeros(1,(length(r) - length(P)-1))];    
        end
    end
    
    P = [P zeros(1,(length(r) - length(P)))]; % updating size of popularity vector

    if sum(r) > 0
        P = (1 - alpha) * P + alpha*(r/sum(r)); % updating popularity
    end
    
    if ~isempty(S)
        c = cca(P,S,d,D,C); % CCA
        n = sum(c); 

        if strcmp(type, 'Comparison')   
            for q = 1:N
                c1(q,:) = lfu (r1(q,:),S,C(q)); % LFU        
                c2(q,:) = lru(r2{q},S,C(q)); % LRU
                c3(q,:) = cca_greedy(r1(q,:),S,C(q)); % CCA-Greedy  
            end

            n1 = sum(c1);
            n2 = sum(c2);
            n3 = sum(c3); 
        end

        % Computing reoptimization bytes

        if sum(n>n_0) > 0
            nb = find(n>n_0); % Number of updates across the caches
            for j = 1: length(nb)
                if n_0(nb(j)) == 0
                    rfb = rfb + S(nb(j)) ; % updating remote reopt.
                    lfb  = lfb + (n(nb(j))-1)*S(nb(j)); % updating local reopt.
                else
                    lfb = lfb + (n(nb(j))-n_0(nb(j)))*S(nb(j)); % updating local reopt.
                end
            end
        end
        n_0 = n;

        if strcmp(type, 'Comparison') 

            if sum(n1>n_01) > 0
                nb = find(n1>n_01);
                for j = 1: length(nb)
                    if n_01(nb(j)) == 0
                        rfb1 = rfb1 + S(nb(j));  
                        lfb1  = lfb1 + (n1(nb(j))-1)*S(nb(j));
                    else
                        lfb1 = lfb1 + (n1(nb(j))-n_01(nb(j)))*S(nb(j));  
                    end
                end
            end

            if sum(n2>n_02) > 0
                nb = find(n2>n_02); 

                for j = 1: length(nb)
                    if n_02(nb(j)) == 0
                        rfb2 = rfb2 + S(nb(j));  
                        lfb2  = lfb2 + (n2(nb(j))-1)*S(nb(j));
                    else
                        lfb2 = lfb2 + (n2(nb(j))-n_02(nb(j)))*S(nb(j));  
                    end
                end
            end

            if sum(n3>n_03) > 0
                nb = find(n3>n_03); 
                for j = 1: length(nb)
                    rfb3 = rfb3 + S(nb(j)) ; 
                end
            end

            n_01 = n1;
            n_02 = n2;
            n_03 = n3;
        end
    end

    % Updating the dynamic performance characteristics at the end of each
    % window

    Dc = [Dc dc];
    Ch = [Ch ch]; 
    Cm = [Cm cm]; 
    Rfb = [Rfb rfb];
    Rtb = [Rtb rtb];
    Lfb = [Lfb lfb];
    Ltb = [Ltb ltb];
    
    Chm = [Chm mean(Ch)]; 
    Cmm = [Cmm mean(Cm)]; 
    Dcm = [Dcm mean(Dc)];
    Rfbm = [Rfbm mean(Rfb)];
    Rtbm = [Rtbm mean(Rtb)];
    Lfbm = [Lfbm mean(Lfb)];
    Ltbm = [Ltbm mean(Ltb)];

    if strcmp(type,'Comparison')
        Dc1 = [Dc1 dc1];
        Ch1 = [Ch1 ch1]; 
        Cm1 = [Cm1 cm1]; 
        Rfb1 = [Rfb1 rfb1];
        Rtb1 = [Rtb1 rtb1];
        Lfb1 = [Lfb1 lfb1];
        Ltb1 = [Ltb1 ltb1];
    
        Dc2 = [Dc2 dc2];
        Ch2 = [Ch2 ch2]; 
        Cm2 = [Cm2 cm2];
        Rfb2 = [Rfb2 rfb2];
        Rtb2 = [Rtb2 rtb2];
        Lfb2 = [Lfb2 lfb2];
        Ltb2 = [Ltb2 ltb2];
    
        Dc3 = [Dc3 dc3];
        Ch3 = [Ch3 ch3]; 
        Cm3 = [Cm3 cm3]; 
        Rfb3 = [Rfb3 rfb3];
        Rtb3 = [Rtb3 rtb3];

        Chm1 = [Chm1 mean(Ch1)];
        Cmm1 = [Cmm1 mean(Cm1)]; 
        Dcm1 = [Dcm1 mean(Dc1)];
        Rfbm1 = [Rfbm1 mean(Rfb1)];
        Rtbm1 = [Rtbm1 mean(Rtb1)];
        Lfbm1 = [Lfbm1 mean(lfb1)];
        Ltbm1 = [Ltbm1 mean(ltb1)];
    
        Chm2 = [Chm2 mean(Ch2)];
        Cmm2 = [Cmm2 mean(Cm2)]; 
        Dcm2 = [Dcm2 mean(Dc2)];
        Rfbm2 = [Rfbm2 mean(Rfb2)];
        Rtbm2 = [Rtbm2 mean(Rtb2)];
        Lfbm2 = [Lfbm2 mean(Lfb2)];
        Ltbm2 = [Ltbm2 mean(Ltb2)];
    
        Chm3 = [Chm3 mean(Ch3)]; 
        Cmm3 = [Cmm3 mean(Cm3)]; 
        Dcm3 = [Dcm3 mean(Dc3)];
        Rfbm3 = [Rfbm3 mean(Rfb3)];
        Rtbm3 = [Rtbm3 mean(Rtb3)];
    end  
end

if strcmp(type,'Time Evolution')
    % figure;
    % plot(Cm)
    % hold on;
    % plot(Ch)
    % xlabel('Window No')
    % ylabel('Number of Cache hits/misses')
    % title('Cache Hit/miss variation with time')
    % legend('Cache Misses','Cache Hits')
    % 
    % figure;
    % plot(Rtb,'-b','Linewidth',2)
    % hold on;
    % plot(Ltb,'-r','Linewidth',2)
    % % ylim([0 0.5*10^11])
    % xlabel('Window Index')
    % ylabel('Number of Bytes Fetched')
    % title('Fetched Bytes with time')
    % legend('Remote Fetching','Local Fetching')
    % 
    % figure;
    % plot(Rfb,'-b','Linewidth',2)
    % hold on;
    % plot(Lfb,'-r','Linewidth',2)
    % xlabel('Window Index')
    % ylabel('Number of Bytes Fetched at the end of a window')
    % title('Fetched Bytes with time at the end of a window')
    % legend('Remote Fetching','Local Fetching')
    % 
    % figure;
    % plot(Rtb+Rfb,'-b','Linewidth',2)
    % hold on;
    % plot(Ltb+Rfb,'-r','Linewidth',2)
    % xlabel('Window Index')
    % ylabel('Number of Total Bytes Fetched')
    % title('Total Fetched Bytes with time')
    % legend('Remote Fetching','Local Fetching')
    
    % figure;
    % plot(Dc)
    % % ylim([0 2*10^4])
    % xlabel('Window Index')
    % ylabel('Instantaneous Delay')
    % grid on;
    % % title('Instantaneous Delay with time')
    
    figure;
    plot(Cmm,'--r','Linewidth',2)
    hold on;
    plot(Chm,'-b','Linewidth',2)
    xlabel('Window No')
    ylabel('Average Number of Cache hits/misses')
    grid on;
    % title('Average Cache Hit/miss variation with time')
    legend('Cache Misses','Cache Hits')
    
    figure;
    plot(Rtbm/(w_l*10^9),'-b','Linewidth',2)
    hold on;
    plot(Ltbm/(w_l*10^9),'--r','Linewidth',2)
    xlabel('Window Number')
    ylabel('Average Delivery Bytes per Request (GB)')
    grid on;
    %title('Average Fetched Bytes with time')
    legend('Remote Fetched Bytes','Local Fetched Bytes')
    
    figure;
    plot(Rfbm/(w_l*10^9),'-b','MarkerFaceColor','k','Linewidth',2)
    hold on;
    plot(Lfbm/(w_l*10^9),'--r','MarkerFaceColor','k','Linewidth',2)
    xlabel('Window Number')
    ylabel('Average Reoptimization Bytes per Request (GB)')
    grid on;
    %title('Average Fetched Bytes with time at the end of a window')
    legend('Remote Fetched Bytes','Local Fetched Bytes')
    
    figure;
    plot((Rtbm+ Rfbm)/(w_l*10^9),'-b','MarkerFaceColor','k','Linewidth',2)
    hold on;
    plot((Ltbm+ Lfbm)/(w_l*10^9),'--r','MarkerFaceColor','k','Linewidth',2)
    % hold on;
    % plot(Rtbm/(10^12),'--b','MarkerFaceColor','k','Linewidth',2)
    % hold on;
    % plot(Ltbm/(10^12),'--r','MarkerFaceColor','k','Linewidth',2)
    xlabel('Window Number')
    ylabel('Average Fetched Bytes per Request (GB)')
    grid on;
    % title('Average Total Fetched Bytes with time')
    legend('Remote Fetched Bytes','Local Fetched Bytes')
    
    figure;
    plot(Dcm,'Linewidth',2)
    % ylim([0 2*10^4])
    xlabel('Window Number')
    ylabel('Average Delay ')
    grid on;
    % title('Average Delay with time')
end

avg_rtb = sum(Rtb)/(w_l*length(Rtb));
avg_ltb = sum(Ltb)/(w_l*length(Rtb));
avg_rfb = sum(Rfb)/(w_l*length(Rtb));
avg_lfb = sum(Lfb)/(w_l*length(Rtb));
avg_Dc = sum(Dc)/(w_l*length(Dc));


if strcmp(type,'Comparison')
    figure;
    plot(Dcm/w_l,'-b','Linewidth',2)
    hold on;
    plot(Dcm1/w_l,'--r','Linewidth',2)
    hold on;
    plot(Dcm2/w_l,':g','Linewidth',2)
    hold on;
    plot(Dcm3/w_l,'-.k','Linewidth',2)
    xlabel('Window Number')
    ylabel('Average Delay per request(s)')
    grid on;
    % title('Average Delay with time')
    legend('CCA','LFU','LRU','CCA (no collab.)')
    % legend('With Collaboration','Without Collaboration')

    avg_lfb1 = sum(Lfb1)/(w_l*length(Rtb1));
    avg_ltb1 = sum(Ltb1)/(w_l*length(Rtb1));
    avg_rtb1 = sum(Rtb1)/(w_l*length(Rtb1));
    avg_rfb1 = sum(Rfb1)/(w_l*length(Rtb1));
    avg_Dc1 = sum(Dc1)/(w_l*length(Dc1));
    
    avg_lfb2 = sum(Lfb2)/(w_l*length(Rtb2));
    avg_ltb2 = sum(Ltb2)/(w_l*length(Rtb2));
    avg_rtb2 = sum(Rtb2)/(w_l*length(Rtb2));
    avg_rfb2 = sum(Rfb2)/(w_l*length(Rtb2));
    avg_Dc2 = sum(Dc2)/(w_l*length(Dc2));
    
    avg_rtb3 = sum(Rtb3)/(w_l*length(Rtb3));
    avg_rfb3 = sum(Rfb3)/(w_l*length(Rtb3));
    avg_Dc3 = sum(Dc3)/(w_l*length(Dc3));
   
    a_rtb = [avg_rtb avg_rtb1 avg_rtb2 avg_rtb3];
    a_rfb = [avg_rfb avg_rfb1 avg_rfb2 avg_rfb3];
    a_ltb = [avg_ltb avg_ltb1 avg_ltb2 0];
    a_lfb = [avg_lfb avg_lfb1 avg_lfb2 0];
    a_dc =  [avg_Dc avg_Dc1 avg_Dc2 avg_Dc3];
else
    a_rtb = avg_rtb;
    a_ltb = avg_ltb;
    a_rfb = avg_rfb;
    a_lfb = avg_lfb;
    a_dc = avg_Dc;
end