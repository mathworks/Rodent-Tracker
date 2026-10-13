classdef RodentTracker_SAP_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_SAP_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerSAPDetectionUIFigure  matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveStatsMenu                   matlab.ui.container.Menu
        GridLayout                      matlab.ui.container.GridLayout
        SpeedThresholdcmsSlider         matlab.ui.control.Slider
        SpeedThresholdcmsSliderLabel    matlab.ui.control.Label
        EccentricityThresholdSliderLabel  matlab.ui.control.Label
        EccentricityThresholdSlider     matlab.ui.control.Slider
        UItable                         matlab.ui.control.Table
        LoadGroundTruthButton           matlab.ui.control.Button
        CalculateButton                 matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        Callingapp
        GroundTruth
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, MainApp)
            app.Callingapp = MainApp;

            app.RodentTrackerSAPDetectionUIFigure.Visible = "off";
            app.RodentTrackerSAPDetectionUIFigure.Units = 'normalized';
            app.RodentTrackerSAPDetectionUIFigure.Position = [0.3 0.3 0.35 0.55];
            app.RodentTrackerSAPDetectionUIFigure.Units = 'pixel';
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            app.Callingapp.SAPDetection = zeros(size(app.Callingapp.Eccentricity));
            app.Callingapp.SAPDetection(app.Callingapp.Eccentricity >= app.EccentricityThresholdSlider.Value)=1;
            app.Callingapp.SAPDetection(app.Callingapp.Speed > app.SpeedThresholdcmsSlider.Value)=0;

%             groundTruth = zeros(size(app.Callingapp.SAPDetection));
            [TP,TN,FP,FN,Sensitivity,Specificity,Accuracy,MCC,Fscore] = Tracking_stats(app.Callingapp.SAPDetection,app.GroundTruth);

            t = table;
            t.TP = TP;
            t.TN = TN;
            t.FP = FP;
            t.FN = FN;
            t.Sensitivity = Sensitivity;
            t.Specificity = Specificity;
            t.Accuracy = Accuracy;
            t.MCC = MCC;
            t.Fscore = Fscore;

            set(app.UItable,"Data",t)

            if (app.UIAxes.Children)<2
                bar(app.UIAxes,app.Callingapp.SAPDetection)
            else
                cla(app.UIAxes)
                bar(app.UIAxes,app.GroundTruth)
                hold(app.UIAxes,"on")
                bar(app.UIAxes,app.Callingapp.SAPDetection)
            end
        end

        % Button pushed function: LoadGroundTruthButton
        function LoadGroundTruthButtonPushed(app, event)
            [filename, folder] = uigetfile;
            data = load(fullfile(folder,filename));
            app.GroundTruth = data.GroundTruth;
            bar(app.UIAxes,app.GroundTruth)
            hold(app.UIAxes,"on")

            figure(app.RodentTrackerSAPDetectionUIFigure)
        end

        % Menu selected function: SaveStatsMenu
        function SaveStatsMenuSelected(app, event)
            app.Callingapp.ProgressText.Text = 'Saving Spreadsheet...';
            filter = {'*.mat';'*.xls';'*.xlsx';'*.csv'};
            [file,path] = uiputfile(filter);
            filename = fullfile(path,file);
            [~,~,ext] = fileparts(filename);
            Validation_stats = app.RodentTrackerSAPDetectionUIFigure.Children(1).Data;
            if strcmp(ext,'.mat')
                save(filename,'Validation_stats')
            else
                writetable(Validation_stats,filename);
            end
            app.Callingapp.ProgressText.Text = 'Validation Statistics Saved';
        end

        % Close request function: RodentTrackerSAPDetectionUIFigure
        function RodentTrackerSAPDetectionUIFigureCloseRequest(app, event)
            app.RodentTrackerSAPDetectionUIFigure.Visible ="off";
            app.Callingapp.SAPMenu.Checked = "off";
            app.Callingapp.Spreadsheet_Window.SAPMenu.Checked = "off";
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_SAP_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end