local Run = game:GetService("RunService")
local Selection = game:GetService("Selection")

if Run:IsRunning() then return end

local Utils = require(script.Utils)

local toolbar = plugin:CreateToolbar("Benchmarking")
local run = toolbar:CreateButton(
    "Benchmark Selection",
    "Benchmarks all functions defined in selected ModuleScripts",
    "rbxassetid://52756150"
)


local function output(text, callback, ...)
    local formatted = string.format("[BenchmarkAutoHook] %s", text)

    if not callback then
        return formatted
    end

    callback(formatted, text, ...)
end


local function onRunClick()
    local succeeded = 0
    local selected = Selection:Get()
    local total = #selected

    for _, instance in ipairs(selected) do
        if not instance:IsA("ModuleScript") then
            continue
        end

        local success, errorOrModule = pcall(require, instance)

        if not success then
            local message = string.format("Skipping %s due to error - %s", instance.Name, error)

            output(message, warn)
            continue
        end

        for attribute, callback in pairs(errorOrModule) do
            if typeof(callback) ~= "function" then
                continue
            end

            local success, error = pcall(callback)

            if not success then
                local message = string.format("Skipping %s due to error - %s", attribute, error)

                output(message, warn)
                continue
            end

            local formatted = string.format("%s:", attribute)
            succeeded += 1

            output(formatted, warn)
            Utils.timeit(callback)
        end
    end

    local message = string.format("Successfully benchmarked %d/%d ModuleScripts", succeeded, total)

    output(message, print)
end


run.Click:Connect(onRunClick)
print("[BenchmarkAutoHook] Started")
