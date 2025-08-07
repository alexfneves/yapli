#include <string>
#include <iostream>
#include <inja/inja.hpp>
#include <nlohmann/json.hpp>
#include <emscripten/emscripten.h>
#include <dirent.h>

// Make sure we're using the correct namespaces
using json = nlohmann::json;
using namespace std;



void listFiles(const char* path) {
    DIR* dir = opendir(path);
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            std::cout << entry->d_name << "\n";
        }
        closedir(dir);
    } else {
        std::cerr << "Could not open directory: " << path << "\n";
    }
}

// This function takes a template string and JSON context string,
// and returns the rendered HTML as a std::string.
extern "C" {
EMSCRIPTEN_KEEPALIVE
const char* render(const char* component, const char* contextStr) {
    try {
        listFiles("/");
        static std::string resultStorage; // static to avoid dangling pointer
        inja::Environment env;

        // Parse the JSON context
        json context = json::parse(contextStr);

        // Render the template
        std::string file = "/" + std::string(component) + ".html";
        std::cout << file << std::endl;
        resultStorage = env.render_file(file, context);

        // Return a pointer to the result (lives in static storage)
        return resultStorage.c_str();
    } catch (const std::exception& e) {
        std::cerr << "Error in render: " << e.what() << std::endl;
        return "Error during rendering";
    }
}
}
