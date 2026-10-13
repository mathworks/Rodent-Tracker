classdef RodentTracker_Background_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_Background_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        BackgroundUIFigure              matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
    end



    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, RodentTracker)
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            %Position
            app.BackgroundUIFigure.Units = 'normalized';
%             app.BackgroundUIFigure.Position = [0.32 0.39 0.22 0.34];
            app.BackgroundUIFigure.Position = [0.06+0.47*(yres/xres)+(((0.9426-0.47*(yres/xres)-(0.06+0.47*(yres/xres)))-0.47*(yres/xres))/2) 0.3 0.47*(yres/xres) 0.47];

            app.UIAxes.Units = 'normalized';
            app.UIAxes.Position = [0 0 1 1];
            axis(app.UIAxes,'ij')
            hold(app.UIAxes,"on")    

            app.BackgroundUIFigure.Visible ="off";
        end

        % Close request function: BackgroundUIFigure
        function BackgroundUIFigureCloseRequest(app, event)
            app.BackgroundUIFigure.Visible ="off";
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_Background_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end