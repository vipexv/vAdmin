// Spaghetti code up ahead!

import React, { useState, useEffect } from "react";
import "./Main.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { isEnvBrowser } from "../utils/misc";
import PlayerList from "./PlayerList";
import {
  CarFront,
  Cross,
  MoreHorizontal,
  ShieldCheck,
  ShieldHalf,
  ShieldX,
  UserSquare,
  UserX2,
  Users,
  X,
} from "lucide-react";

import { motion } from "framer-motion";
import { useToast } from "@/components/ui/use-toast";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";

import Button from "@mui/joy/Button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

import Input from "@mui/joy/Input";
import { Label } from "@/components/ui/label";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

const testPerms = {
  "Car Wipe": true,
  Armor: true,
  "Player Names": true,
  Spectate: true,
  Heal: true,
  "Clear Chat": true,
  Kick: true,
  Freeze: true,
  Unban: true,
  Revive: true,
  Menu: true,
  "Offline Ban": true,
  Ban: true,
  Teleport: true,
  NoClip: true,
};

const examplePlayerData: PlayerData[] = Array.from(
  { length: 100 },
  (_, index) => ({
    name: `Test Dummy ${index + 1}`,
    id: index + 1,
    identifiers: [
      "license:6c5a04a27880f9ef14f177cd52b495d6d9517187",
      "xbl:2535413463113628",
      "live:844425900550524",
      "discord:470311257589809152",
      "fivem:1124792",
      "license2:6c5a04a27880f9ef14f177cd52b495d6d9517187",
    ],
    tokens: [
      "3:6ee006eb015de6d96eeb4ffb186c6f914eb26710705cc84e390e0a710c2fc7da",
      "2:9beaca997de990b97451bf48e45648e70dece18eaf70d4089806689838d97cc4",
      "5:4c21ed333227a0780dbf446cf6ce463c52f1e128f6ee12cc94e1ce0cbb9c7501",
      "4:89e1d1a48495d9eacee361c4c81aec7c0a4fca1ad6da7ef480edf9726d6a2f94",
      "4:353da103a6cacd356b2d33d41fa554038a2606946661515ba94a98d599aaeca5",
      "4:b14d1e1a4ed3aa2387d8f0f601eb94e9bd27c9ab42170e59b5bf9c0dfe244077",
    ],
  })
);

debugData([
  {
    action: "nui:adminperms",
    data: testPerms,
  },
]);

debugData([
  {
    action: "nui:clist",
    data: examplePlayerData,
  },
]);

debugData([
  {
    action: "nui:plist",
    data: examplePlayerData,
  },
]);

type Tabs = {
  Players: boolean;
  SelfOptions: boolean;
  Utilities: boolean;
  Cache: boolean;
  BanList: boolean;
};

type PlayerData = {
  name: string | null;
  id: number | null;
  identifiers: any;
  tokens: any;
};

type BanData = {
  target_id: number;
  reason: string;
  length: string;
};
type OfflineBanData = {
  reason: string;
  length: string;
  identifiers: any | null;
  playerName: string | null;
  tokens: any | null;
};

type KickData = {
  target_id: number;
  reason: string;
};

interface PlayerMenuPermissionV2 {
  "Car Wipe": boolean;
  Armor: boolean;
  "Player Names": boolean;
  Spectate: boolean;
  Heal: boolean;
  "Clear Chat": boolean;
  Kick: boolean;
  Freeze: boolean;
  Unban: boolean;
  Revive: boolean;
  Menu: boolean;
  "Offline Ban": boolean;
  Ban: boolean;
  Teleport: boolean;
  NoClip: boolean;
}

type selectedOptions = {
  health: boolean;
  armor: boolean;
  playerNames: boolean;
  carWipe: boolean;
  clearChat: boolean;
};

const Main: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [sourcePerms, setSourcePerms] = useState<PlayerMenuPermissionV2>({
    "Car Wipe": false,
    Armor: false,
    "Player Names": false,
    Spectate: false,
    Heal: false,
    "Clear Chat": false,
    Kick: false,
    Freeze: false,
    Unban: false,
    Revive: false,
    Menu: false,
    "Offline Ban": false,
    Ban: false,
    Teleport: false,
    NoClip: false,
  });

  const [currentTab, setCurrentTab] = useState<Tabs>({
    Players: true,
    SelfOptions: false,
    Utilities: false,
    Cache: false,
    BanList: false,
  });

  const { toast } = useToast();

  const [players, setPlayers] = useState<PlayerData[]>([]);
  const [banID, setBanID] = useState("");
  const [cachedPlayers, setCachedPlayers] = useState<PlayerData[]>([]);
  const [filteredPlayerList, setFilteredPlayerList] = useState<PlayerData[]>(
    []
  );
  const [filteredCacheList, setFilteredCacheList] = useState<PlayerData[]>([]);
  const [banData, setBanData] = useState<BanData>({
    target_id: 0,
    length: "",
    reason: "",
  });
  const [offlineBanData, setOfflineBanData] = useState<OfflineBanData>({
    length: "",
    reason: "",
    playerName: "",
    identifiers: null,
    tokens: null,
  });

  const [selectedOptions, setSelectedOptions] = useState<selectedOptions>({
    health: false,
    armor: false,
    playerNames: false,
    carWipe: false,
    clearChat: false,
  });

  const [kickData, setKickData] = useState<KickData>({
    target_id: 0,
    reason: "",
  });

  const [banLength, setBanLength] = useState("");
  const [banReason, setBanReason] = useState("");
  const [offlineBanLength, setOfflineBanLength] = useState("");
  const [offlineBanReason, setOffineBanReason] = useState("");
  const [kickReason, setKickReason] = useState("");

  const [banModalOpen, setBanModalOpen] = useState(false);

  const [searchQuery, setSearchQuery] = useState<string>("");
  const [cacheSearchQuery, setCacheSearchQuery] = useState<string>("");

  useNuiEvent<PlayerData[]>("nui:plist", (data) => {
    setPlayers(data);
  });

  useNuiEvent<PlayerMenuPermissionV2>("nui:adminperms", async (perms) => {
    try {
      setSourcePerms(perms);
    } catch (error) {
      console.error("Error updating state:", error);
    }
  });

  useNuiEvent<PlayerData[]>("nui:clist", (cachedPlayers) => {
    setCachedPlayers(cachedPlayers);
  });

  useNuiEvent<boolean>("setVisible", setVisible);

  useNuiEvent("nui:notify", (message: string) => {
    toast({
      variant: "default",
      description: message,
      className: "rounded font-inter",
    });
  });

  useEffect(() => {
    try {
      const filtered = players
        ? Object.values(players).filter((player) => {
            if (!player || !player.id || !player.name) return;
            const playerId = player.id?.toString().toLowerCase();
            const query = searchQuery.toLowerCase();
            return (
              player.name.toLowerCase().includes(query) ||
              playerId.includes(query)
            );
          })
        : [];
      setFilteredPlayerList(filtered);
    } catch (error) {
      console.log(error);
    }
  }, [searchQuery]);

  useEffect(() => {
    try {
      const filtered = cachedPlayers
        ? Object.values(cachedPlayers).filter((player) => {
            if (!player || !player.id || !player.name) return;
            const playerId = player.id?.toString().toLowerCase();
            const query = cacheSearchQuery.toLowerCase();
            return (
              player.name.toLowerCase().includes(query) ||
              playerId.includes(query)
            );
          })
        : [];
      setFilteredCacheList(filtered);
    } catch (error) {
      console.log(error);
    }
  }, [cacheSearchQuery]);

  const fetchClient = () => {
    fetchNui("vadmin:client:options", selectedOptions);
    selectedOptions.armor = false;
    selectedOptions.health = false;
    selectedOptions.playerNames = false;
    selectedOptions.carWipe = false;
    selectedOptions.clearChat = false;
  };

  const fetchUnban = () => {
    if (!banID) {
      toast({
        variant: "destructive",
        description: "Ban id is not specified.",
        className: "rounded font-inter",
      });
    }
    fetchNui("vadmin:client:unban", banID);
    setBanID("");
    hideNui();
  };

  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        if (!isEnvBrowser()) {
          setCurrentTab({
            Players: true,
            SelfOptions: false,
            Utilities: false,
            Cache: false,
            BanList: false,
          });
          setBanData({
            target_id: 0,
            length: "",
            reason: "",
          });
          fetchNui("hideFrame");
        } else setVisible(!visible);
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => window.removeEventListener("keydown", keyHandler);
  }, [visible]);

  const hideNui = () => {
    setCurrentTab({
      Players: true,
      SelfOptions: false,
      Utilities: false,
      Cache: false,
      BanList: false,
    });
    setBanData({
      target_id: 0,
      length: "",
      reason: "",
    });
    setBanLength("");
    setBanReason("");
    setOfflineBanData({
      length: "",
      reason: "",
      identifiers: null,
      playerName: "",
      tokens: null,
    });
    setOfflineBanLength("");
    setKickReason("");
    setKickData({
      target_id: 0,
      reason: "",
    });
    fetchNui("hideFrame");
  };

  return (
    <>
      {!!visible && (
        <>
          <div className="w-screen h-screen flex flex-col gap-2 justify-center items-center">
            <motion.div
              className="bg-black rounded boxshadow bg-opacity-80"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{
                type: "spring",
                stiffness: 260,
                damping: 20,
              }}
            >
              <div className="text-white flex gap-32 justify-between font-inter font-bold text-sm p-4">
                <button
                  className={`rounded transition p-2 flex justify-center items-center active:scale-90 ${
                    currentTab.Players ? "bg-slate-700 bg-opacity-50" : ""
                  }`}
                  style={{
                    borderColor: "#059669",
                  }}
                  onClick={() =>
                    setCurrentTab({
                      Players: true,
                      SelfOptions: false,
                      Utilities: false,
                      Cache: false,
                      BanList: false,
                    })
                  }
                >
                  <Users size="16px" className="mr-1" /> Players
                </button>
                <DropdownMenu>
                  <DropdownMenuTrigger
                    className="border p-2 flex items-center justify-center"
                    style={{
                      borderColor: "#059669",
                    }}
                  >
                    <MoreHorizontal size="16px" className="mr-1" /> Utilities
                  </DropdownMenuTrigger>
                  <DropdownMenuContent className="rounded border-none font-bold font-inter">
                    <DropdownMenuLabel>Utilities</DropdownMenuLabel>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem
                      className="text-xs"
                      disabled={!sourcePerms["Car Wipe"]}
                      onSelect={(e) => {
                        selectedOptions.carWipe = true;
                        fetchClient();
                        console.log("Done");
                      }}
                    >
                      <CarFront size={"16px"} className="mr-1" />
                      Car Wipe
                    </DropdownMenuItem>

                    <DropdownMenuItem
                      className="text-xs"
                      disabled={!sourcePerms["Clear Chat"]}
                      onSelect={(e) => {
                        selectedOptions.clearChat = true;
                        fetchClient();
                        console.log("Done");
                      }}
                    >
                      <X size={"16px"} className="mr-1" />
                      Clear Chat
                    </DropdownMenuItem>
                    <Dialog open={banModalOpen} onOpenChange={setBanModalOpen}>
                      <DialogTrigger asChild disabled={!sourcePerms.Unban}>
                        <Button
                          variant="plain"
                          color="danger"
                          className="w-full"
                        >
                          <ShieldX size="16px" className="mr-1" />
                          Unban
                        </Button>
                      </DialogTrigger>
                      <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                        <DialogHeader>
                          <DialogTitle>Unban Player</DialogTitle>
                          <DialogDescription>
                            Input the players Ban id.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                          <div className="flex items-center gap-1">
                            <Label htmlFor="name" className="text-right">
                              Ban id:
                            </Label>

                            <Input
                              id="name"
                              onChange={(e) => {
                                setBanID(e.target.value);
                              }}
                              className="rounded"
                            />
                          </div>
                        </div>
                        <DialogFooter>
                          <Button
                            color="danger"
                            type="submit"
                            onClick={() => {
                              setBanModalOpen(false);
                              fetchUnban();
                            }}
                            className="rounded outline-none"
                          >
                            Confirm
                          </Button>
                        </DialogFooter>
                      </DialogContent>
                    </Dialog>
                  </DropdownMenuContent>
                </DropdownMenu>
                <DropdownMenu>
                  <DropdownMenuTrigger
                    className="border p-2 flex items-center justify-center"
                    style={{
                      borderColor: "#059669",
                    }}
                  >
                    <ShieldCheck size="16px" className="mr-1" /> Self Options
                  </DropdownMenuTrigger>
                  <DropdownMenuContent className="rounded border-none font-bold font-inter">
                    <DropdownMenuLabel>Self Options</DropdownMenuLabel>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem
                      className="text-xs"
                      disabled={!sourcePerms.Heal}
                      onSelect={(e) => {
                        selectedOptions.health = true;
                        fetchClient();
                        console.log("Done");
                      }}
                    >
                      <Cross size={"16px"} className="mr-1" />
                      Heal
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      className="text-xs"
                      disabled={!sourcePerms.Armor}
                      onSelect={(e) => {
                        selectedOptions.armor = true;
                        fetchClient();
                        console.log("Done");
                      }}
                    >
                      <ShieldHalf size={"16px"} className="mr-1" />
                      Armor
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      className="text-xs"
                      disabled={!sourcePerms["Player Names"]}
                      onSelect={(e) => {
                        selectedOptions.playerNames = true;
                        fetchClient();
                        console.log("Done");
                      }}
                    >
                      <UserSquare size={"16px"} className="mr-1" /> Player Names
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
                <button
                  className={`rounded transition p-2 flex justify-center items-center active:scale-90 ${
                    currentTab.Cache ? "bg-slate-700 bg-opacity-50" : ""
                  }`}
                  style={{
                    borderColor: "#059669",
                  }}
                  onClick={() =>
                    setCurrentTab({
                      Players: false,
                      SelfOptions: false,
                      Utilities: false,
                      BanList: false,
                      Cache: true,
                    })
                  }
                >
                  <UserX2 size={"16px"} className="mr-1" /> Player Cache
                </button>
              </div>
              {currentTab.Players ? (
                <motion.div
                  className="text-white"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{
                    type: "spring",
                    stiffness: 260,
                    damping: 20,
                  }}
                >
                  <div className="flex justify-end items-center px-2 py-2">
                    <input
                      type="text"
                      className="outline-none w-fit float-right py-1 px-2 mb-2 bg-transparent rounded font-inter focus:-translate-y-1 transition"
                      style={{
                        border: "2px solid #059669",
                        borderColor: "#059669",
                      }}
                      placeholder="Search..."
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value);
                      }}
                    />
                  </div>
                  <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow">
                    {!!players && !searchQuery && (
                      <PlayerList
                        playerList={players}
                        cached={false}
                        sourcePerms={sourcePerms}
                      />
                    )}
                  </div>
                  {searchQuery && (
                    <>
                      <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow">
                        {
                          <PlayerList
                            playerList={filteredPlayerList}
                            cached={false}
                            sourcePerms={sourcePerms}
                          />
                        }
                      </div>
                    </>
                  )}
                </motion.div>
              ) : currentTab.SelfOptions ? (
                <></>
              ) : currentTab.Cache ? (
                <>
                  <div className="flex justify-end items-center px-2 py-2">
                    <input
                      type="text"
                      className="outline-none w-fit float-right py-1 px-2 mb-2 bg-transparent rounded font-inter focus:-translate-y-1 transition text-white font-inter"
                      style={{
                        border: "2px solid #059669",
                        borderColor: "#059669",
                      }}
                      placeholder="Search..."
                      value={cacheSearchQuery}
                      onChange={(e) => {
                        setCacheSearchQuery(e.target.value);
                      }}
                    />
                  </div>
                  <div className="grid grid-cols-4 gap-5 mt-2 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow text-white">
                    {!cacheSearchQuery && (
                      <PlayerList
                        playerList={cachedPlayers}
                        cached={true}
                        sourcePerms={sourcePerms}
                      />
                    )}
                    {cacheSearchQuery && (
                      <PlayerList
                        playerList={filteredCacheList}
                        cached={true}
                        sourcePerms={sourcePerms}
                      />
                    )}
                  </div>
                </>
              ) : (
                <></>
              )}
            </motion.div>
            <div className="bg-black bg-opacity-50 rounded p-1 rouned text-white font-inter text-bold text-xs boxshadow">
              <p>Copyright © vipex 2023. All rights reserved.</p>
            </div>
          </div>
        </>
      )}
    </>
  );
};

export default Main;
