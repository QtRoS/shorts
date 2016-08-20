 **** README for Joey ****

Now project has following structure:

|---shorts-app
 	|---shorts
 	|	|---- * sources *
 	|--- * some configuration files * (Let me call it "qmake configuration files, qcf")

We decided to keep both CMake and qmake working in parallel, so here is my plan - you should put your CMake configuration files (ccf) inside "shorts" folder (near to sources), and do not touch qcf at root folder. In such case they can work together - qmake for develiping, CMake for autotests and so on. 



Next idea - we should use name "shorts" whenever it possible. In trunk of "ubuntu-rssreader-app" already a lot of things called "shorts" (for example main qml file or *.apparmor file). But we must use "ubuntu-rssreader-app" as name of our project in launchpad. In all other places I prefer "shorts".
