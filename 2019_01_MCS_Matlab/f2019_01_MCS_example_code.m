%Example 1
%------------------------------------------------
rate = 10; %Hz
pt = mcs.stg.pulse_train.fixed_rate(rate);
plot(pt)

set(gca,'FontSize',16,'FontName','Arial');

sl.plot.uimenu.addExportSVGOption();



%Example 2
%------------------------------------------------
amp = 10; %mA
duration = 100; %us
w = mcs.stg.waveform.biphasic(amp,duration,'amp_units','mA','duration_units','us');
rate = 20; %Hz
pt = mcs.stg.pulse_train.fixed_rate(rate,'waveform',w);

subplot(2,1,1)
plot(w)
set(gca,'FontSize',16,'FontName','Arial');
title('Waveform')
subplot(2,1,2)
plot(pt)
set(gca,'FontSize',16,'FontName','Arial');
title('Pulse train')


%Example 3 
%-------------------------------------------------
pt = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',8);
plot(pt)
set(gca,'FontSize',16,'FontName','Arial');
title('Pulse train')
