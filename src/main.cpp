#include <string>
#include <iostream>
#include <inja/inja.hpp>
#include <nlohmann/json.hpp>
#include <emscripten/emscripten.h>

// Make sure we're using the correct namespaces
using json = nlohmann::json;
using namespace std;

// This function takes a template string and JSON context string,
// and returns the rendered HTML as a std::string.
extern "C" {
EMSCRIPTEN_KEEPALIVE
const char* render(const char* templateStr, const char* contextStr) {
    try {
        static std::string resultStorage; // static to avoid dangling pointer
        inja::Environment env;

        // Parse the JSON context
        json context = json::parse(contextStr);

        // Render the template
        resultStorage = env.render(templateStr, context);

        // Return a pointer to the result (lives in static storage)
        return resultStorage.c_str();
    } catch (const std::exception& e) {
        std::cerr << "Error in render: " << e.what() << std::endl;
        return "Error during rendering";
    }
}
}
