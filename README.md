# Purescript Kickstarter

A way to get started and get yourself onboarded with a new PureScript project. (Using: `react`, `react-basic-hooks`, `parcel`, `npm` )

There are two options:

- just clone the repository and start working on it (not for beginners);
- go through the setup step by step and get yourself familiar with it.

## Option A. Just clone

This options assumes that you have `npm` installed and familiar with PureScript tooling (in case you run into any problems, see the following **Option B**)

```shell
npm install
npm start
```

## Option B. Deep dive

We are going to cover a basic way to set up a PureScript project: how to build it, how to install and use JavaScript libraries (packages), how to test and publish it.

### Tooling and setting things up

In case you are bored or have no ready project to copy, you can set up the PureScript project by yourself.

Each paragraph covers one of the tools: how to install it, what is it doing, and why you should care.

It's recommended to have a [PureScript language server](https://github.com/nwolverson/purescript-language-server) working with an editor, e.g. you could use VSCode with [ide-purescript](https://marketplace.visualstudio.com/items?itemName=nwolverson.ide-purescript)

#### Initialize the project (`npm`)

`npm` is a dependency/package manager. It lets us install packages both globally and locally. For example, we are going to use it to install `spago` in the next step.

First thing is to [install `npm`](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm). After that we can create a project directory and initialize the project. We use the `-y` option for `npm` to install without asking us any questions.

```shell
mkdir purescript-kickstarter && cd purescript-kickstarter
npm init -y
```

The project directory contains a `package.json`, which holds the metadata about the project: project name, version, a list of dependencies, etc. This json enables `npm` to do tasks, such as installing dependencies, running scripts, starting and publishing the project. When you install a package using the `npm` cli, the package is downloaded to the `node_modules/` directory and an entry is added to your dependencies in the `package.json` (it contains the name of the package and the installed version).

#### Add PureScript (`purs` and `spago`)

Let's start using `npm` and install `purescript` compiler and `spago` package manager. You could either install them globally or locally.

**Option A. Install globally**

- `npm install purescript spago --global`
- could run `spago` directly (e.g. `spago init`)

**Option B. Install locally**

- `npm install purescript spago --save-dev`
- could run `spago` using `npm` scripts or using `npx` (e.g. `npx spago init`)
- Note: `npx` is a CLI tool that let us run locally installed (available on your $PATH) packages, as well as not previously installed packages

So what is [`spago`](https://github.com/purescript/spago)? `spago` is a PureScript package manager and a build tool. Also it has [a nice tutorial](https://github.com/purescript/spago#super-quick-tutorial), which we can follow.

```shell
spago init
```

This command initializes a sample PureScript project. It creates a `src` and a `test` directories, along with a couple of spago configuration files:

- `packages.dhall`: holds available PureScript packages. It is initialized with the official [package-set](https://github.com/purescript/package-sets) (a curated list of packages that work together), and you could override existing or add new packages to it (because this project only uses packages from the package-set, we aren't going to update it; but in case you need to, the file itself contains the instructions on how to do it)

- `spago.dhall`: contains spago settings, such as list of dependencies, paths to the sources, and packages (initially and usually point to the `packages.dhall`).

Note: [`Dhall`](https://github.com/dhall-lang/dhall-lang) is a programmable configuration language, and you could find different levels of tutorials [here](https://github.com/dhall-lang/dhall-lang#tutorials)

Time to build the project:

```shell
spago build
```

This is going to download the dependencies and compile the project into the `output/` directory.

#### Add JavaScript (`parcel` and others)

The current setup allows us to run and test pure PureScript projects, but we won't be able to go far with just PureScript. We have to add another build tool, which is going to bundle everything together, optimize JavaScript, and produce production files when we are ready to ship. There are multiple options here (the most popular `webpack` and `parcel` are covered in [spago's tutorial](https://github.com/purescript/spago#make-a-project-with-purescript--javascript)). We are going to use `parcel`.

We start by installing `parcel`:

```
npm install parcel --save-dev
```

Then we have to add an `index.js` file, which is going to call the `main` PureScript function. We are going to drop this file in `src/`, but you could place it in the project's root directory or wherever you prefer.

The minimum JavaScript here is to import and call the `main` (from the `output/`, not `src/`):

```js
import { main } from "../output/Main";

main();
```

However it's very helpful to configure [hot reloading](https://parceljs.org/features/development/#hot-reloading) to improve the development experience, so the file should look like this:

```js
import { main } from "../output/Main";

if (module.hot) {
  module.hot.accept(function () {
    main();
  });
}

main();
```

JavaScript file can't source itself, so we need to add an `index.html` file. The file will go to `public/` directory, but feel free to place it in the project's root directory or wherever you prefer. And while we are here, let's add a `styles.css` to the same folder.

Our `index.html` is going to point to `styles.css`, `index.js`, as well as declare a div with `app` id, that we are going to use later to render our React component.

```html
<!DOCTYPE html>
<html>
  <head>
    <title>PureScript Kickstarter</title>
    <link rel="stylesheet" href="./styles.css" />
    <link rel="icon" href="./favicon.ico" type="image/x-icon" />
  </head>
  <body>
    <div id="app"></div>
    <script src="../src/index.js" type="module"></script>
  </body>
</html>
```

There is not much to see yet, but you could serve the app already. To make our life easier we could add a build and start scripts to the `package.json`:

```json
  "scripts": {
    "build": "spago build",
    "prestart": "npm run build",
    "start": "parcel serve public/index.html --open"
  },
```

Using `npm` scripts is kind of similar to using `npx`, it treats dependencies (e.g. `parcel`) as if they were installed locally.

The `parcel serve` command starts a development server and opens it in the browser (because of the `--open` flag). When you run the start script, you will see that your server is running and the app is open (should be `localhost:1234` by default):

```shell
npm start
```

`parcel serve` is going to automatically rebuild the app as you change the files. This doesn't apply to the PureScript source files, but only applies to the output of `spago build`. If you're going to use an editor integration for writing PureScript (any editor that uses `purs ide server`), it's going to recompile the files as you save them, so you don't have to worry about it. Otherwise you could make `spago` watch for file changes and automatically rebuild with a flag `--watch`. This command should run concurrently (in another terminal) to the `npm start`, and we could add it to the scripts as well:

```json
  "scripts": {
    "build:watch": "spago build --watch",
  }
```

### Add a React component

Okay, let's build something random: a rectangle which can appear in a random position using [react-basic-hooks](https://github.com/spicydonuts/purescript-react-basic-hooks). You could read more about the React Hooks in [the official overview](https://reactjs.org/docs/hooks-overview.html).

First we need to install `react` and `react-dom` packages, `react-basic` and `react-basic-hooks` PureScript packages, as well as additional dependencies.

```shell
npm install --save react react-dom

spago install react-basic react-basic-dom react-basic-hooks

spago install exceptions maybe random web-dom web-html
```

Now we can add a React component and update the `main` function:

```purescript
module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import Effect.Random (randomInt)
import React.Basic.DOM (css, render)
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Hooks (Component, component, useState', (/\))
import React.Basic.Hooks as React
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

-- | Find the element with `app` id, that we declared in `index.html`.
-- | Create and render a component tree into this element,
-- | Or crash in case we messed up during the setup.
main :: Effect Unit
main = do
  doc <- document =<< window
  container <- getElementById "app" $ toNonElementParentNode doc
  randomBox <- mkRandomBox
  case container of
    Nothing -> throw "Could not find container element"
    Just c -> render (randomBox {}) c

-- | An effectful function that creates a react component without any props.
-- | Uses a State Hook to manage the position of the box.
mkRandomBox :: Component {}
mkRandomBox = do
  component "RandomBox" \_ -> React.do
    -- returns a stateful position, and a function to update it
    { x, y } /\ setPosition <- useState' { x: 100, y: 100 }

    -- renders a box at the {x, y} position with a button to change a position
    pure $ R.div
      { className: "box"
      , style: css
          { position: "absolute"
          , top: show x <> "px"
          , left: show y <> "px"
          }
      , children:
          [ R.div
              { className: "screen"
              }
          , R.button
              { className: "button"
              , children: [ R.text "Click me" ]
              , onClick: handler_ do
                  newX <- randomInt 100 500
                  newY <- randomInt 100 500
                  setPosition { x: newX, y: newY }
              }
          ]
      }
```

Some `css` to make it nicer (put it into the `styles.css` we've created earlier):

```css
.box {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.screen {
  background-color: gray;
  height: 360px;
  width: 640px;
}
```

And finally we could see something. You could run it (in case you haven't):

```shell
npm start
```

You could find more examples of using React with PureScript in the [PureScript Cookbook](https://github.com/JordanMartinez/purescript-cookbook) and learn more about gradually extending existing React application in [How to Write PureScript React Components to Replace JavaScript](https://thomashoneyman.com/articles/replace-react-components-with-purescript/)

### Add a Foreign React component (FFI)

To make it more interesting and real, we could add a react component published by someone else. For example, we could use [react-player](https://www.npmjs.com/package/react-player) to show a video player instead of a lame gray box.

```shell
npm install --save react-player
```

PureScript has very nice [FFI (Foreign Function Interface)](https://github.com/purescript/documentation/blob/master/guides/FFI.md) to call the JavaScript code.

JavaScript code is wrapped using a foreign module, which should have the same name as a corresponding PureScript module. In our case we are going to create `ReactPlayer.js` in the directory `src/Foreign/` (arbitrary name):

```javascript
const reactPlayer = require("react-player");
exports.reactPlayer = reactPlayer.default;
```

FFI lets you enforce as much type safety as you need. We have to assign a type to the exported component from the foreign module, we could add just the props we care about: `className`, `controls`, `light`, `url`, and leave out the rest. The companion PureScript module `ReactPlayer` is going to be placed in `src/Foreign/ReactPlayer.purs` and look like this:

```purescript
module Foreign.ReactPlayer where

import React.Basic.Hooks (ReactComponent)

foreign import reactPlayer
  :: ReactComponent
    { className :: String
    , controls :: Boolean
    , light :: Boolean
    , url :: String
    }
```

The component is ready and we can use it instead of the box:

```purescript
R.div
  { className: "screen"
  }
```

We create a new component:

```purescript
element reactPlayer
  { className: "screen"
  , controls: true
  , light: true
  , url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }
```

We also need to add a couple of imports:

```purescript
import Foreign.ReactPlayer (reactPlayer)
import React.Basic.Hooks (element)
```

And with this our application is complete.

### Final bundle

Now we are ready to bundle everything and deploy our application. Let's make a final adjustment to the `package.json` and add production build scripts:

```json
"scripts": {
  "prebundle": "npm run build",
  "bundle": "parcel build public/index.html",
},
```

Parcel bundles and optimizes the application for production. Check out the `dist/` directory after running `npm run bundle`.
