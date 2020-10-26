function sl = montecarloCG(n_list,hr_list,T_list,k_list,iso_source,flag_method,x)

% prepare a nested for loop to run multiple times the Craig-Gordon model
% implementation for different input parameter values

%preallocate a vector with all the slopes
N = length(n_list)*length(hr_list)*length(T_list)*length(k_list);
sl=zeros(N,1); 

% get slopes 
nn=0; %preallocate a counter
    for n = n_list
        for hr = hr_list
            for T = T_list
                for k = k_list
                    nn=nn+1; %update the counter
                    hr_perc = min(hr/100,0.98); %hr in percentage. Use a min to avoid 99% and 100% which are numerically problematic
                    sl(nn)=f_fractionation_CraigGordon_slim([n,hr_perc,T,k],iso_source,flag_method,x);
                end
            end
        end
    end
    
end