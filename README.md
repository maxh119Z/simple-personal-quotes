# simple-personal-quotes

## add your own personal quotes widget with custom quotes in a simple app.
<img width="359" height="175" alt="image" src="https://github.com/user-attachments/assets/9297ee45-e033-4945-9900-fdd7cd6f5267" />

## what you need
* **a macbook**
* **xcode**

## install and run
1. Clone this repository in Xcode
```
git clone https://github.com/maxh119Z/simple-personal-quotes.git
```
3. Open `personal_quotes.xcodeproj`

### configure for your device
You need to sign your own Apple ID to run.
1. In Xcode, click the blue **personal_quotes** project icon at the top of the left sidebar.
2. Under the **Targets** list, click on the main app: **`personal_quotes`**.
3. Go to the **Signing & Capabilities** tab.
4. Check the box for **"Automatically manage signing"**.
5. Under **Team**, select your Personal Team (log in if needed).
6. Under **Bundle Identifier**, change `personal.personal-quotes` to something unique (e.g., `[your name].personal-quotes`).

### some more updating
App Groups must be globally unique. You need to replace my App Group with your own.
1. Still in the **Signing & Capabilities** tab for the `personal_quotes` target, look at the **App Groups** section.
2. Delete the existing group (`group.personalQuotes`) by selecting it and clicking the minus (`-`) button.
3. Click the plus (`+`) button and create a new, unique group name (e.g., `group.[your name].quotes`). 
4. **Repeat Steps 2 & 3** for the widget target: Click **`QuoteWidgetExtension`** in the left Targets list, go to Signing & Capabilities, and add that *same* App Group you just created.

### Step 4: Update the Code
Now, just tell the code to look for your new App Group.
1. Open `ContentView.swift`. Use **Cmd + F** to find the string `"group.personalQuotes"` (it appears in the `loadQuotes` and `saveData` functions). Change it to your new App Group name.
2. Open `QuoteWidget.swift` and do the exact same thing (it appears once in the `getQuotes` function).

### Step 5: Install the App 
1. In the top-center of Xcode, ensure the scheme selector says **personal_quotes** and the destination is **My Mac**.
2. Press the **Play** button or  `Cmd + R` to build and run the app.
3. Look at your Mac's Dock. Right-click the new app icon, select **Options > Show in Finder**.
4. Drag the `.app` file into your Mac's **Applications** folder. 
5. Double-click it from the Applications folder once to register it with macOS.

### Step 6: Add the Widget to Your Desktop
1. Just how you normally add widgets!
2. Feel free to edit the app logo in assets


<img width="719" height="571" alt="image" src="https://github.com/user-attachments/assets/3d3c9bfd-06ee-4e8a-8b81-cbeba1a1048c" />
<img width="887" height="621" alt="image" src="https://github.com/user-attachments/assets/cc7b1216-26f0-4a69-941f-7c086c90e8d9" />
<img width="362" height="174" alt="image" src="https://github.com/user-attachments/assets/b7127c89-1550-4e7b-87ca-a6c16dd80226" />
