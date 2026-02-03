import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import localFont from "next/font/local";
import "./globals.css";
import { FontSizeProvider } from "@/context/FontSizeContext";

// Use Inter font (same as ChatGPT) for better readability
const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  weight: ["300", "400", "500", "600", "700"],
});

const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  title: "HowAI - Your Personal AI Agent",
  description: "Own your AI agent completely. HowAI is your personalized AI assistant that adapts to your style, learns your preferences, and works exclusively for you. Create your custom AI personality, set your preferred communication style, and build your own AI companion that grows with you.",
  keywords: [
    "personal AI agent",
    "custom AI assistant",
    "personalized AI",
    "AI personality customization",
    "private AI agent",
    "your own AI",
    "intelligent assistant",
    "AI companion",
    "custom AI personality",
    "personal AI helper"
  ],
  authors: [{ name: "HowAI Team" }],
  creator: "HowAI",
  publisher: "HowAI",
  category: "Artificial Intelligence",
  openGraph: {
    title: "HowAI - Your Personal AI Agent",
    description: "Own your AI agent completely. Create a custom AI personality that adapts to your style and works exclusively for you.",
    type: "website",
    locale: "en_US",
    siteName: "HowAI",
    images: [
      {
        url: "/howai-icon.png",
        width: 512,
        height: 512,
        alt: "HowAI - Your Personal AI Agent"
      }
    ]
  },
  twitter: {
    card: "summary_large_image",
    title: "HowAI - Your Personal AI Agent",
    description: "Own your AI agent completely. Create a custom AI personality that works exclusively for you.",
    images: ["/howai-icon.png"],
    creator: "@howai"
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  manifest: "/manifest.json",
  icons: {
    icon: [
      { url: "/howai-icon.png", sizes: "32x32", type: "image/png" },
      { url: "/howai-icon.png", sizes: "16x16", type: "image/png" },
    ],
    apple: [
      { url: "/howai-icon.png", sizes: "180x180", type: "image/png" },
    ],
    other: [
      {
        rel: "apple-touch-icon-precomposed",
        url: "/howai-icon.png",
      },
    ],
  },
  applicationName: "HowAI",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "HowAI - Your Personal AI Agent",
  },
  formatDetection: {
    telephone: false,
  },
  other: {
    "mobile-web-app-capable": "yes",
    "apple-mobile-web-app-capable": "yes",
    "apple-mobile-web-app-status-bar-style": "default",
    "theme-color": "#000000",
    "msapplication-TileColor": "#000000",
    "msapplication-config": "/browserconfig.xml"
  }
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${inter.variable} ${geistMono.variable} antialiased`}
      >
        <FontSizeProvider>
          {children}
        </FontSizeProvider>
      </body>
    </html>
  );
}
