classdef RodentTracker_ROI_Results_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_ROI_Results_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerROIResultsUIFigure  matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveasMenu                      matlab.ui.container.Menu
        UITable                         matlab.ui.control.Table
    end

    properties (Access = private)
        Callingapp
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, Mainapp)
            %Position
            app.RodentTrackerROIResultsUIFigure.Units = 'normalized';
            app.RodentTrackerROIResultsUIFigure.Position(1) = 0.3;
            app.RodentTrackerROIResultsUIFigure.Position(2) = 0.3;
            app.RodentTrackerROIResultsUIFigure.Units = 'pixels';
            app.RodentTrackerROIResultsUIFigure.Visible = 'off';
            
            app.Callingapp = Mainapp;
        end

        % Menu selected function: SaveasMenu
        function SaveasMenuSelected(app, event)
            app.Callingapp.ProgressText.Text = 'Saving ROI Results...';
            filter = {'*.mat';'*.xls';'*.xlsx';'*.csv'};
            [file,path] = uiputfile(filter);
            filename = fullfile(path,file);
            [~,~,ext] = fileparts(filename);
            ROI_Results = app.RodentTrackerROIResultsUIFigure.Children(1).Data;
            if strcmp(ext,'.mat')
                save(filename,'ROI_Results')
            else
                writetable(ROI_Results,filename);
            end
            app.Callingapp.ProgressText.Text = 'ROI Results Saved';
        end

        % Close request function: RodentTrackerROIResultsUIFigure
        function RodentTrackerROIResultsUIFigureCloseRequest(app, event)
            app.RodentTrackerROIResultsUIFigure.Visible ="off";
            app.Callingapp.ROIresultsMenu.Checked = "off";
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_ROI_Results_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end