"use client";

import { logout } from "@/lib/server";
import { useRouter } from "next/navigation";
export default function Home() {
  const router = useRouter();
  const handleLogout = () => {
    logout();
    router.push("/login");
  };
  return <div></div>;
}
