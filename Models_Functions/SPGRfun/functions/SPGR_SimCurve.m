function SimCurveResults = SPGR_SimCurve(Fit, Prot, FitOpt )

FitOpt.R1map = 0;
FitOpt.R1reqR1f = 0;
FitOpt.fx(6) = true;

xFit = [Fit.F, Fit.kr, Fit.R1f, Fit.R1r, Fit.T2f, Fit.T2r];
Fit.table = xFit';

offsets = unique(Prot.Offsets);
OffsetCurve = zeros(length(offsets)*4 +2,1);
OffsetCurve(1) = 100;
OffsetCurve(end) = max(offsets) + 1000;
maxOff = 100;
offsets = [0; offsets];
ind = 4;
for i = 2:length(offsets)
    OffsetCurve(ind-2) = 0.5*(offsets(i) + offsets(i-1));
    OffsetCurve(ind-1) = offsets(i) - maxOff;
    OffsetCurve(ind) = offsets(i);
    OffsetCurve(ind+1) = offsets(i) + maxOff;
    ind = ind + 4;
end

AngleCurve  =  unique(Prot.Angles);
[Prot.Angles, Prot.Offsets] = SPGR_GetSeq(AngleCurve,OffsetCurve);
[Angles, Offsets, w1cw, w1rms, w1rp, Tau] = SPGR_prepare( Prot );
Prot.Tau = Tau(1);

% Fitted curve
switch FitOpt.model    
    case 'SledPikeCW'
        FitOpt.WB = computeWB(w1cw, Offsets, Fit.T2r, FitOpt.lineshape);
        xData = [Angles, Offsets, w1cw];
        func = @SPGR_Scw_fun;       
    case 'SledPikeRP'
        FitOpt.WB = computeWB(w1rp, Offsets, Fit.T2r, FitOpt.lineshape);
        xData = [Angles, Offsets, w1rp];
        func = @SPGR_Srp_fun;        
    case 'Yarnykh'
        FitOpt.WB = computeWB(w1rms, Offsets, Fit.T2r, FitOpt.lineshape);
        xData = [Offsets, w1rms];
        func = @SPGR_Y_fun;      
    case 'Ramani'
        FitOpt.WB = computeWB(w1cw, Offsets, Fit.T2r, FitOpt.lineshape);
        xData = [Offsets, w1cw];
        func = @SPGR_R_fun;    
end

Mcurve = func(xFit, xData, Prot, FitOpt);
Mcurve = reshape(Mcurve,length(OffsetCurve),length(AngleCurve));
Fit.curve = Mcurve;
Fit.Offsets = OffsetCurve;
SimCurveResults = Fit;

end