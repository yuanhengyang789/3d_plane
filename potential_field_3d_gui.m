function potential_field_3d_gui()
    % 创建主窗口
    fig = figure('Name', '3D人工势场路径规划', 'NumberTitle', 'off', ...
                'Position', [100, 100, 1000, 700], 'Color', 'white');
    
    % 创建3D坐标轴
    ax = axes('Parent', fig, 'Position', [0.1, 0.2, 0.6, 0.7]);
    axis(ax, [0 10 0 10 0 10]);
    grid(ax, 'on');
    hold(ax, 'on');
    view(ax, 3);
    title(ax, '3D人工势场路径规划');
    xlabel(ax, 'X轴');
    ylabel(ax, 'Y轴');
    zlabel(ax, 'Z轴');
    
    % 初始化变量
    start_point = [1, 1, 1];
    goal_point = [9, 9, 9];
    obstacles = [];
    path = [];
    is_setting_obstacles = false;
    
    % 创建图形对象句柄
    h_start = plot3(ax, start_point(1), start_point(2), start_point(3), 'bo', ...
                  'MarkerSize', 10, 'MarkerFaceColor', 'b');
    h_goal = plot3(ax, goal_point(1), goal_point(2), goal_point(3), 'rp', ...
                 'MarkerSize', 15, 'MarkerFaceColor', 'r');
    h_obstacles = scatter3(ax, NaN, NaN, NaN, 100, 'k', 'filled');
    h_path = plot3(ax, NaN, NaN, NaN, 'b-', 'LineWidth', 1.5);
    
    % 创建UI控件
    uicontrol('Style', 'pushbutton', 'String', '设置起点', ...
             'Position', [750, 550, 200, 40], ...
             'Callback', @set_start_point);
    
    uicontrol('Style', 'pushbutton', 'String', '设置终点', ...
             'Position', [750, 500, 200, 40], ...
             'Callback', @set_goal_point);
    
    uicontrol('Style', 'pushbutton', 'String', '添加障碍物', ...
             'Position', [750, 450, 200, 40], ...
             'Callback', @add_obstacles);
    
    uicontrol('Style', 'pushbutton', 'String', '清除障碍物', ...
             'Position', [750, 400, 200, 40], ...
             'Callback', @clear_obstacles);
    
    uicontrol('Style', 'pushbutton', 'String', '开始规划', ...
             'Position', [750, 350, 200, 40], ...
             'Callback', @run_algorithm);
    
    uicontrol('Style', 'pushbutton', 'String', '重置场景', ...
             'Position', [750, 300, 200, 40], ...
             'Callback', @reset_scene);
    
    % 参数设置面板
    uipanel('Title', '算法参数', 'Position', [0.72, 0.05, 0.25, 0.18]);
    
    uicontrol('Style', 'text', 'String', '引力系数:', ...
             'Position', [760, 120, 80, 20], 'HorizontalAlignment', 'left');
    h_att_coeff = uicontrol('Style', 'edit', 'String', '0.8', ...
                          'Position', [840, 120, 100, 20]);
    
    uicontrol('Style', 'text', 'String', '斥力系数:', ...
             'Position', [760, 90, 80, 20], 'HorizontalAlignment', 'left');
    h_rep_coeff = uicontrol('Style', 'edit', 'String', '5', ...
                          'Position', [840, 90, 100, 20]);
    
    uicontrol('Style', 'text', 'String', '斥力范围:', ...
             'Position', [760, 60, 80, 20], 'HorizontalAlignment', 'left');
    h_rep_thresh = uicontrol('Style', 'edit', 'String', '3', ...
                           'Position', [840, 60, 100, 20]);
    
    % 鼠标点击回调函数 (仅用于障碍物设置)
    set(fig, 'WindowButtonDownFcn', @mouse_click);
    
    % 回调函数定义
    function set_start_point(~, ~)
        % 创建输入对话框
        prompt = {'X坐标 (0-10):', 'Y坐标 (0-10):', 'Z坐标 (0-10):'};
        dlgtitle = '设置起点坐标';
        dims = [1 35];
        definput = {num2str(start_point(1)), num2str(start_point(2)), num2str(start_point(3))};
        answer = inputdlg(prompt, dlgtitle, dims, definput);
        
        if ~isempty(answer)
            % 验证输入
            x = str2double(answer{1});
            y = str2double(answer{2});
            z = str2double(answer{3});
            
            if ~isnan(x) && ~isnan(y) && ~isnan(z) && ...
               x >= 0 && x <= 10 && y >= 0 && y <= 10 && z >= 0 && z <= 10
                start_point = [x, y, z];
                set(h_start, 'XData', x, 'YData', y, 'ZData', z);
                disp(['起点设置为: [' num2str(x) ', ' num2str(y) ', ' num2str(z) ']']);
            else
                errordlg('请输入0-10范围内的有效坐标值', '输入错误');
            end
        end
    end
    
    function set_goal_point(~, ~)
        % 创建输入对话框
        prompt = {'X坐标 (0-10):', 'Y坐标 (0-10):', 'Z坐标 (0-10):'};
        dlgtitle = '设置终点坐标';
        dims = [1 35];
        definput = {num2str(goal_point(1)), num2str(goal_point(2)), num2str(goal_point(3))};
        answer = inputdlg(prompt, dlgtitle, dims, definput);
        
        if ~isempty(answer)
            % 验证输入
            x = str2double(answer{1});
            y = str2double(answer{2});
            z = str2double(answer{3});
            
            if ~isnan(x) && ~isnan(y) && ~isnan(z) && ...
               x >= 0 && x <= 10 && y >= 0 && y <= 10 && z >= 0 && z <= 10
                goal_point = [x, y, z];
                set(h_goal, 'XData', x, 'YData', y, 'ZData', z);
                disp(['终点设置为: [' num2str(x) ', ' num2str(y) ', ' num2str(z) ']']);
            else
                errordlg('请输入0-10范围内的有效坐标值', '输入错误');
            end
        end
    end
    
    function add_obstacles(~, ~)
        choice = questdlg('选择障碍物设置方式:', '添加障碍物', ...
                         '输入精确坐标', '鼠标点击添加', '取消', '输入精确坐标');
        
        switch choice
            case '输入精确坐标'
                % 创建输入对话框
                prompt = {'X坐标 (0-10):', 'Y坐标 (0-10):', 'Z坐标 (0-10):'};
                dlgtitle = '添加障碍物坐标';
                dims = [1 35];
                answer = inputdlg(prompt, dlgtitle, dims);
                
                if ~isempty(answer)
                    % 验证输入
                    x = str2double(answer{1});
                    y = str2double(answer{2});
                    z = str2double(answer{3});
                    
                    if ~isnan(x) && ~isnan(y) && ~isnan(z) && ...
                       x >= 0 && x <= 10 && y >= 0 && y <= 10 && z >= 0 && z <= 10
                        obstacles = [obstacles; x, y, z];
                        update_obstacles_plot();
                        disp(['添加障碍物于: [' num2str(x) ', ' num2str(y) ', ' num2str(z) ']']);
                    else
                        errordlg('请输入0-10范围内的有效坐标值', '输入错误');
                    end
                end
                
            case '鼠标点击添加'
                is_setting_obstacles = true;
                disp('请点击3D视图添加障碍物 (右键结束)');
                
            case '取消'
                % 不做任何操作
        end
    end
    
    function clear_obstacles(~, ~)
        obstacles = [];
        update_obstacles_plot();
        disp('已清除所有障碍物');
    end
    
    function reset_scene(~, ~)
        start_point = [1, 1, 1];
        goal_point = [9, 9, 9];
        obstacles = [];
        path = [];
        
        set(h_start, 'XData', start_point(1), 'YData', start_point(2), 'ZData', start_point(3));
        set(h_goal, 'XData', goal_point(1), 'YData', goal_point(2), 'ZData', goal_point(3));
        update_obstacles_plot();
        set(h_path, 'XData', NaN, 'YData', NaN, 'ZData', NaN);
        
        disp('场景已重置');
    end
    
    function mouse_click(~, ~)
        if ~is_setting_obstacles
            return;
        end
        
        % 获取鼠标点击位置对应的3D坐标
        cp = get(ax, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        z = cp(1,3);
        
        % 检查点击是否在坐标轴范围内
        if x < 0 || x > 10 || y < 0 || y > 10 || z < 0 || z > 10
            return;
        end
        
        % 检查是否是右键点击 (结束障碍物设置)
        if strcmp(get(fig, 'SelectionType'), 'alt')
            is_setting_obstacles = false;
            disp('障碍物设置完成');
        else
            obstacles = [obstacles; x, y, z];
            update_obstacles_plot();
            disp(['添加障碍物于: [' num2str(x) ', ' num2str(y) ', ' num2str(z) ']']);
        end
    end
    
    function update_obstacles_plot()
        if ~isempty(obstacles)
            set(h_obstacles, 'XData', obstacles(:,1), ...
                            'YData', obstacles(:,2), ...
                            'ZData', obstacles(:,3));
        else
            set(h_obstacles, 'XData', NaN, 'YData', NaN, 'ZData', NaN);
        end
    end
    
    function run_algorithm(~, ~)
        % 获取参数值
        attraction_coeff = str2double(get(h_att_coeff, 'String'));
        repulsion_coeff = str2double(get(h_rep_coeff, 'String'));
        repulsion_threshold = str2double(get(h_rep_thresh, 'String'));
        
        % 检查参数有效性
        if isnan(attraction_coeff) || isnan(repulsion_coeff) || isnan(repulsion_threshold)
            errordlg('请输入有效的参数值', '参数错误');
            return;
        end
        
        % 运行算法
        disp('开始3D路径规划...');
        
        % 算法参数
        d_threshold = 1.0;        % 斥力衰减阈值
        step_size = 0.1;          % 步长
        max_iter = 2000;          % 最大迭代次数
        perturb_range = 0.5;      % 扰动范围
        position = start_point;   % 当前位置
        path = position;          % 路径记录
        
        % 清除旧路径
        set(h_path, 'XData', NaN, 'YData', NaN, 'ZData', NaN);
        drawnow;
        
        % 主循环
        for iter = 1:max_iter
            % 计算各力
            F_att = attraction_force_3d(position, goal_point, attraction_coeff);
            F_rep = repulsion_force_3d(position, obstacles, repulsion_coeff, ...
                                      repulsion_threshold, goal_point, d_threshold);
            F_total = F_att + F_rep;
            
            % 添加随机扰动
            if norm(F_total) < 0.1
                F_total = F_total + random_perturbation_3d(perturb_range);
            end
            
            % 动态调整步长
            if ~isempty(obstacles)
                min_dist = min(vecnorm(position - obstacles, 2, 2));
                if min_dist < repulsion_threshold
                    step = step_size * (0.9 + 0.2*rand());
                else
                    step = step_size;
                end
            else
                step = step_size;
            end
            
            % 更新位置
            if norm(F_total) > 0
                direction = F_total / norm(F_total);
                position = position + step * direction;
                path = [path; position];
            end
            
            % 更新路径显示
            set(h_path, 'XData', path(:,1), 'YData', path(:,2), 'ZData', path(:,3));
            set(h_start, 'XData', position(1), 'YData', position(2), 'ZData', position(3));
            
            % 每50次迭代更新一次显示
            if mod(iter, 50) == 0
                drawnow;
            end
            
            % 终止条件
            if norm(position - goal_point) < 0.3
                disp('成功到达目标点!');
                break;
            end
        end
        
        if iter == max_iter
            disp('达到最大迭代次数，可能未找到路径');
        end
        
        % 最终更新显示
        drawnow;
    end
end

%% 3D引力计算
function F = attraction_force_3d(pos, goal, k_att)
    F = -k_att * (pos - goal);
end

%% 3D斥力计算
function F = repulsion_force_3d(pos, obstacles, k_rep, rho_0, goal, d_th)
    F = [0, 0, 0];
    if isempty(obstacles)
        return;
    end
    
    dist_to_goal = norm(pos - goal);
    decay = min(1.0, dist_to_goal/d_th);
    
    for i = 1:size(obstacles,1)
        delta = pos - obstacles(i,:);
        dist = norm(delta);
        if dist < rho_0
            term1 = (1/dist - 1/rho_0) * (1/dist^3);
            F = F + k_rep * term1 * delta * decay;
        end
    end
end

%% 3D随机扰动
function pert = random_perturbation_3d(range)
    pert = range * (2*rand(1,3) - 1); % 生成[-range, range]的扰动
end