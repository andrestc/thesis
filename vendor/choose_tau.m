function tau = choose_tau( signals )

tau = [];
for i=1:size(signals,1)
    [~, locs] = findpeaks(-mutual(signals(i,:), 128));
    try
        tau = [tau; locs(1)-1];
    catch
    end
end

tau = mode(tau);
%if tau == 0
    %tau = 1;
%end

end

