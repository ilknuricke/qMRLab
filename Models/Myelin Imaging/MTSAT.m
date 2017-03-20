classdef MTSAT
% ----------------------------------------------------------------------------------------------------
% MTSAT :  Magnetization transfer saturation 
% ----------------------------------------------------------------------------------------------------
    properties
        MRIinputs = {'MT','T1', 'PD', 'Mask'};
        xnames = {};
        voxelwise = 0;
        
        % Protocol
        ProtFormat ={'Flip Angle' 'TR'};
        Prot  = [5 0.031; 5 0.031; 15 0.011]; % You can define a default protocol here.
        
        % Model options
        buttons = {'offset frequency (Hz)', 1000};
        options= struct();
        
    end
    
    methods
        function obj = MTSAT
            obj = button2opts(obj);
        end
        
        function FitResult = fit(obj,data)
            MTparams = obj.Prot(1,:); 
            MTparams(1,1) = MTparams(1,1)*pi()/180; % FA in rad
            PDparams = obj.Prot(2,:); 
            T1params = obj.Prot(3,:);
            
            FitResult = MTSAT_exec(data, MTparams, PDparams, T1params);
            
            % change colormap for custom MTSAT colormap
            % ColorMapStyle_Callback: colormap(maps{val})
            load('MTSAT.mat'); % load the colormap
            %RefreshColorMap(handles)
            
        end
        
        function plotmodel(obj, Fit, data)
            % data to plot is in : Fit.(Fit.fields{1})
            FFit = Fit.(Fit.fields{1});
            NDimensions = ndims(FFit);
            if NDimensions == 1 || (NDimensions == 2 && size(FFit,1) == 1 && size(FFit,2) == 1)
                close(68); % simply display values or image
                msgbox(['Fitting results of voxel [' num2str([data.MT data.T1 data.PD]) '] is ' num2str(Fit.(Fit.fields{1})) ' ']);
            elseif NDimensions == 2
                % carefull when dimensions is (1x1), still a value so don't
                % display
                imagesc(Fit.(Fit.fields{1}));
            end
            
        end
        
    end
end