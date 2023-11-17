import React from "react";
import ReactDOM from "react-dom/client";
import { VisibilityProvider } from "./providers/VisibilityProvider";
import Main from "./components/Main";
import { Toaster } from "@/components/ui/toaster";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <Main />
    <Toaster />
  </React.StrictMode>
);
