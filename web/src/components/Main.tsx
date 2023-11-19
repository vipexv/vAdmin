// Spaghetti code up ahead!

import React, { useState, useEffect } from "react";
import "./Main.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { isEnvBrowser } from "../utils/misc";
import cleanPlayerName from "@/utils/cleanPlayerName";
import {
  ArrowLeftRight,
  ArrowRightLeft,
  CarFront,
  Cross,
  Fingerprint,
  Gavel,
  Glasses,
  Heart,
  MoreHorizontal,
  ShieldCheck,
  ShieldHalf,
  ShieldX,
  Snowflake,
  UserSquare,
  UserX2,
  Users,
  X,
  Zap,
} from "lucide-react";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { motion } from "framer-motion";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

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

type Tabs = {
  Players: boolean;
  SelfOptions: boolean;
  Utilities: boolean;
  Cache: boolean;
  BanList: boolean;
};

type PlayerData = {
  Name: string | null;
  ID: number | null;
  Identifiers: any;
  HWIDS: any;
};

type BanData = {
  target_id: number;
  reason: string;
  length: string;
};
type OfflineBanData = {
  reason: string;
  length: string;
  Identifiers: any | null;
  playerName: string | null;
  HWIDS: any | null;
};

type KickData = {
  target_id: number;
  reason: string;
};

interface PlayerMenuPermission {
  "Set Job": boolean;
  "Car Wipe": boolean;
  "Player Names": boolean;
  "Community Service": boolean;
  Ban: boolean;
  Kick: boolean;
  Report: boolean;
  "Delete Car": boolean;
  Teleport: boolean;
  Spectate: boolean;
  "Give Car": boolean;
  "Clear Chat": boolean;
  "Give Account Money": boolean;
  Revive: boolean;
  Announce: boolean;
  Unban: boolean;
  Frozen: boolean;
  "Offline Ban": boolean;
  "Give Item": boolean;
  Skin: boolean;
  Armor: boolean;
  "Set Gang": boolean;
  "Clear Loadout": boolean;
  "Copy Coords": boolean;
  Menu: boolean;
  "Set Account Money": boolean;
  "Go Back": boolean;
  "Flip Car": boolean;
  Health: boolean;
  "Clear Inventory": boolean;
  NoClip: boolean;
  "Give Weapon": boolean;
  "Spawn Car": boolean;
}

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

const debugMode = false;

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
    Identifiers: null,
    HWIDS: null,
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

  const [kickModalOpen, setKickModalOpen] = useState(false);
  const [banModalOpen, setBanModalOpen] = useState(false);

  const [searchQuery, setSearchQuery] = useState<string>("");
  const [cacheSearchQuery, setCacheSearchQuery] = useState<string>("");

  // useEffect(() => {
  //   if (!debugMode) return;
  //   const min = 10000;
  //   const max = 50000;
  //   // const randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;
  //   const examplePlayerData: PlayerData[] = Array.from(
  //     { length: 100 },
  //     (_, index) => ({
  //       Name: `Test Dummy ${index + 1}`,
  //       ID: index + 1, // Increment the player_id naturally (So cool i know!)
  //       Identifiers: [
  //         "license:6c5a04a27880f9ef14f177cd52b495d6d9517187",
  //         "xbl:2535413463113628",
  //         "live:844425900550524",
  //         "discord:470311257589809152",
  //         "fivem:1124792",
  //         "license2:6c5a04a27880f9ef14f177cd52b495d6d9517187",
  //       ],
  //       HWIDS: [
  //         "3:6ee006eb015de6d96eeb4ffb186c6f914eb26710705cc84e390e0a710c2fc7da",
  //         "2:9beaca997de990b97451bf48e45648e70dece18eaf70d4089806689838d97cc4",
  //         "5:4c21ed333227a0780dbf446cf6ce463c52f1e128f6ee12cc94e1ce0cbb9c7501",
  //         "4:89e1d1a48495d9eacee361c4c81aec7c0a4fca1ad6da7ef480edf9726d6a2f94",
  //         "4:353da103a6cacd356b2d33d41fa554038a2606946661515ba94a98d599aaeca5",
  //         "4:b14d1e1a4ed3aa2387d8f0f601eb94e9bd27c9ab42170e59b5bf9c0dfe244077",
  //       ],
  //     })
  //   );
  //   setPlayers(examplePlayerData);
  //   setCachedPlayers(examplePlayerData);
  // }, []);

  useNuiEvent<PlayerData[]>("nui:plist", (data) => {
    setPlayers(data);
  });

  useNuiEvent<PlayerMenuPermissionV2>("nui:adminperms", async (perms) => {
    try {
      // sourcePerms.Armor = perms.Armor;
      // sourcePerms.Ban = perms.Ban;
      // sourcePerms["Car Wipe"] = perms["Car Wipe"];
      // sourcePerms["Clear Chat"] = perms["Clear Chat"];
      // sourcePerms.Freeze = perms.Freeze;
      // sourcePerms.Heal = perms.Heal;
      // sourcePerms.Kick = perms.Kick;
      // sourcePerms.Menu = perms.Menu;
      // sourcePerms.NoClip = perms.NoClip;
      // sourcePerms["Offline Ban"] = perms["Offline Ban"];
      // sourcePerms["Player Names"] = perms["Player Names"];
      // sourcePerms.Revive = perms.Revive;
      // sourcePerms.Spectate = perms.Spectate;
      // sourcePerms.Teleport = perms.Teleport;
      // sourcePerms.Unban = perms.Unban;

      // Unsure how just using this doesn't actually update it, spaghetti code all the way, i need to re-write most of this.
      setSourcePerms(perms);

      console.log(
        `Source Perms State: ${JSON.stringify(
          sourcePerms
        )}, Perms Param: ${JSON.stringify(perms)}`
      );
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
            if (!player || !player.ID || !player.Name) return;
            const playerId = player.ID?.toString().toLowerCase();
            const query = searchQuery.toLowerCase();
            return (
              player.Name.toLowerCase().includes(query) ||
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
            if (!player || !player.ID || !player.Name) return;
            const playerId = player.ID?.toString().toLowerCase();
            const query = cacheSearchQuery.toLowerCase();
            return (
              player.Name.toLowerCase().includes(query) ||
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
        description: "Ban ID is not specified.",
        className: "rounded font-inter",
      });
    }
    fetchNui("vadmin:client:unban", banID);
    setBanID("");
    hideNui();
  };

  const fetchOfflineBanUser = (player: PlayerData) => {
    if (!offlineBanReason || !offlineBanLength) {
      toast({
        variant: "destructive",
        description: "Ban Reason or Length is not specified.",
        className: "rounded font-roboto",
      });
      return;
    }
    offlineBanData.length = offlineBanLength;
    offlineBanData.reason = offlineBanReason;
    offlineBanData.Identifiers = player.Identifiers;
    offlineBanData.playerName = player.Name;
    offlineBanData.HWIDS = player.HWIDS;

    fetchNui("vadmin:client:offlineban", offlineBanData);

    setOfflineBanData({
      length: "",
      reason: "",
      playerName: "",
      Identifiers: null,
      HWIDS: null,
    });
    setOfflineBanLength("");
    setOffineBanReason("");
  };

  const fetchBanUser = (player: any) => {
    // Move this logic inside the component
    if (!banReason || !banLength) {
      toast({
        variant: "destructive",
        description: "Ban Reason or Length is not specified.",
        className: "rounded font-roboto",
      });
      return;
    }

    banData.length = banLength;
    banData.reason = banReason;
    banData.target_id = player.ID;

    fetchNui("vadmin:nui_cb:ban", banData);

    setBanData({
      target_id: 0,
      length: "",
      reason: "",
    });
    setBanLength("");
    setBanReason("");
    hideNui();
  };

  const fetchTeleport = (player: any, option: string) => {
    player.Option = option;
    fetchNui("vadmin:client:tp", player);
  };

  const fetchRevive = (player: any) => {
    fetchNui("vadmin:client:rev", player);
  };

  const fetchFreeze = (player: any) => {
    fetchNui("vadmin:client:frz", player);
  };

  const fetchSpectate = (player: any) => {
    fetchNui("vadmin:client:spectate", player);
  };

  const fetchKickUser = (player: any) => {
    if (!kickReason) {
      toast({
        variant: "destructive",
        description: "Kick Reason is not specified.",
        className: "rounded font-roboto",
      });
      return;
    }

    kickData.reason = kickReason;
    kickData.target_id = player.ID;

    fetchNui("vadmin:nui_cb:kick", kickData);

    setKickReason("");
    setKickData({
      target_id: 0,
      reason: "",
    });
    hideNui();
  };

  // Then, use fetchBanUser inside your component as needed.

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
      Identifiers: null,
      playerName: "",
      HWIDS: null,
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
                            Input the players Ban ID.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                          <div className="flex items-center gap-1">
                            <Label htmlFor="name" className="text-right">
                              Ban ID:
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
                    {!!players &&
                      !searchQuery &&
                      Object.values(players).map(
                        (player: PlayerData, index: number) => {
                          if (!player || !player.ID || !player.Name) {
                            return;
                          }
                          try {
                            const { displayName, pureName } = cleanPlayerName(
                              player.Name
                            );
                            player.Name = displayName;
                          } catch (error) {
                            console.log(error);
                          }
                          return (
                            <DropdownMenu key={player.ID}>
                              <DropdownMenuTrigger
                                className="rounded text-left p-2 font-semibold bg-black outline-none whitespace-break-spaces break-words"
                                style={{
                                  maxWidth: "250px",
                                }}
                              >
                                {player.Name}{" "}
                                <span className="float-right text-xs bg-green-600 rounded p-1 bg-opacity-50 text-white font-bold font-inter">
                                  ID: {player.ID}
                                </span>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
                                <DropdownMenuLabel
                                  className="font-bold whitespace-break-spaces"
                                  style={{
                                    maxWidth: "250px",
                                  }}
                                >
                                  [{player.ID}] | {player.Name}
                                </DropdownMenuLabel>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem
                                  className="rounded"
                                  disabled={!sourcePerms.Teleport}
                                  onSelect={() => {
                                    fetchTeleport(player, "Goto");
                                  }}
                                >
                                  <ArrowLeftRight
                                    size="16px"
                                    className="mr-1"
                                  />{" "}
                                  Goto
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  disabled={!sourcePerms.Teleport}
                                  className="rounded"
                                  onSelect={() => {
                                    fetchTeleport(player, "Bring");
                                  }}
                                >
                                  <ArrowRightLeft
                                    size="16px"
                                    className="mr-1"
                                  />{" "}
                                  Bring
                                </DropdownMenuItem>
                                <AlertDialog>
                                  <AlertDialogTrigger
                                    className="rounded flex items-center w-full p-1 border-none hover:bg-accent transition"
                                    disabled={!sourcePerms.Menu}
                                  >
                                    {" "}
                                    <Fingerprint
                                      size="16px"
                                      className="mr-1 ml-1"
                                    />{" "}
                                    Identifiers
                                  </AlertDialogTrigger>
                                  <AlertDialogContent className="border-none rounded text-white w-full p-3">
                                    <AlertDialogHeader>
                                      <AlertDialogTitle>
                                        [{player.ID}] | {player.Name}
                                      </AlertDialogTitle>
                                      <AlertDialogDescription>
                                        <div>
                                          <p className="font-inter text-lg text-white mt-3 uppercase font-bold">
                                            Identifier
                                          </p>
                                          {player.Identifiers.map(
                                            (
                                              identifier: any,
                                              index: number
                                            ) => (
                                              <>
                                                <div className="flex flex-col gap-2 rounded text-xs">
                                                  <p>{identifier}</p>
                                                </div>
                                              </>
                                            )
                                          )}
                                        </div>
                                        <div className="mt-10">
                                          <p className="font-inter text-lg text-white mb-2 uppercase font-bold">
                                            Hardware ID
                                          </p>
                                          {player.HWIDS.map(
                                            (hwid: any, index: number) => (
                                              <>
                                                <div className="flex flex-col gap-2 rounded text-xs">
                                                  <p>{hwid}</p>
                                                </div>
                                              </>
                                            )
                                          )}
                                        </div>
                                      </AlertDialogDescription>
                                    </AlertDialogHeader>
                                    <AlertDialogFooter>
                                      {/* <AlertDialogCancel className="rounded">
                                        Cancel
                                      </AlertDialogCancel> */}
                                      <AlertDialogAction className="rounded">
                                        Close
                                      </AlertDialogAction>
                                    </AlertDialogFooter>
                                  </AlertDialogContent>
                                </AlertDialog>
                                <DropdownMenuItem
                                  className="rounded"
                                  disabled={!sourcePerms.Freeze}
                                  onSelect={() => {
                                    fetchFreeze(player);
                                  }}
                                >
                                  {" "}
                                  <Snowflake size="16px" className="mr-1" />
                                  Freeze
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  className="rounded"
                                  disabled={!sourcePerms.Spectate}
                                  onSelect={() => {
                                    fetchSpectate(player);
                                    hideNui();
                                  }}
                                >
                                  <Glasses size="16px" className="mr-1" />
                                  Spectate
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  disabled={!sourcePerms.Revive}
                                  className="rounded mb-1"
                                  onSelect={() => {
                                    fetchRevive(player);
                                  }}
                                >
                                  {" "}
                                  <Heart size="16px" className="mr-1" />
                                  Revive
                                </DropdownMenuItem>
                                <div className="flex flex-row gap-2">
                                  <Dialog
                                    open={kickModalOpen}
                                    onOpenChange={setKickModalOpen}
                                  >
                                    <DialogTrigger
                                      asChild
                                      disabled={!sourcePerms.Kick}
                                    >
                                      <Button
                                        color="danger"
                                        className=""
                                        style={{
                                          borderColor: "gray",
                                        }}
                                      >
                                        <Zap size="16px" className="mr-1" />{" "}
                                        Kick
                                      </Button>
                                    </DialogTrigger>
                                    <DialogContent className="sm:max-w-[425px] text-white rounded border-none">
                                      <DialogHeader>
                                        <DialogTitle>
                                          [{player.ID}] | {player.Name}?
                                        </DialogTitle>
                                        <DialogDescription>
                                          Input a reason for the kick.
                                        </DialogDescription>
                                      </DialogHeader>
                                      <div className="grid gap-4 py-4">
                                        <div className="grid grid-cols-4 items-center gap-4">
                                          <Label
                                            htmlFor="name"
                                            className="text-right"
                                          >
                                            Reason
                                          </Label>
                                          <Input
                                            id="name"
                                            onChange={(e) => {
                                              setKickReason(e.target.value);
                                            }}
                                            className="col-span-3"
                                          />
                                        </div>
                                      </div>
                                      <DialogFooter>
                                        <Button
                                          type="submit"
                                          color="danger"
                                          onClick={(e) => {
                                            setKickModalOpen(false);
                                            fetchKickUser(player);
                                            console.log(player);
                                          }}
                                          className="rounded outline-none"
                                        >
                                          Confirm Kick
                                        </Button>
                                      </DialogFooter>
                                    </DialogContent>
                                  </Dialog>

                                  <Dialog
                                    open={banModalOpen}
                                    onOpenChange={setBanModalOpen}
                                  >
                                    <DialogTrigger
                                      asChild
                                      disabled={!sourcePerms.Ban}
                                    >
                                      <Button color="danger">
                                        <Gavel size="16px" className="mr-1" />
                                        Ban
                                      </Button>
                                    </DialogTrigger>
                                    <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                                      <DialogHeader>
                                        <DialogTitle>
                                          [{player.ID}] | {player.Name}?
                                        </DialogTitle>
                                        <DialogDescription>
                                          Input a reason for the ban.
                                        </DialogDescription>
                                      </DialogHeader>
                                      <div className="grid gap-4 py-4">
                                        <div className="flex items-center gap-1">
                                          <Label
                                            htmlFor="name"
                                            className="text-right"
                                          >
                                            Reason
                                          </Label>

                                          <Input
                                            id="name"
                                            onChange={(e) => {
                                              setBanReason(e.target.value);
                                            }}
                                            className="rounded"
                                          />
                                          <Select
                                            onValueChange={(e: string) => {
                                              setBanLength(e);
                                            }}
                                            required
                                          >
                                            <SelectTrigger className="w-[180px] outline-none rounded">
                                              <SelectValue placeholder="Length" />
                                            </SelectTrigger>
                                            <SelectContent
                                              className="border outline-none rounded font-roboto"
                                              style={{
                                                borderColor: "gray",
                                              }}
                                            >
                                              <SelectItem value="1 Hour">
                                                1 Hour
                                              </SelectItem>
                                              <SelectItem value="3 Hours">
                                                3 Hours
                                              </SelectItem>
                                              <SelectItem value="6 Hours">
                                                6 Hours
                                              </SelectItem>
                                              <SelectItem value="12 Hours">
                                                12 Hours
                                              </SelectItem>
                                              <SelectItem value="1 Day">
                                                1 Day
                                              </SelectItem>
                                              <SelectItem value="3 Days">
                                                3 Day
                                              </SelectItem>
                                              <SelectItem value="1 Week">
                                                1 Week
                                              </SelectItem>
                                              <SelectItem value="1 Month">
                                                1 Month
                                              </SelectItem>
                                              <SelectItem value="3 Months">
                                                3 Months
                                              </SelectItem>
                                              <SelectItem value="6 Months">
                                                6 Months
                                              </SelectItem>
                                              <SelectItem value="1 Year">
                                                1 Year
                                              </SelectItem>
                                              <SelectItem value="Permanent">
                                                Permanent
                                              </SelectItem>
                                            </SelectContent>
                                          </Select>
                                        </div>
                                      </div>
                                      <DialogFooter>
                                        <Button
                                          color="danger"
                                          type="submit"
                                          onClick={(e) => {
                                            setBanModalOpen(false);
                                            fetchBanUser(player);
                                            console.log(player);
                                          }}
                                          className="rounded outline-none"
                                        >
                                          Confirm Ban
                                        </Button>
                                      </DialogFooter>
                                    </DialogContent>
                                  </Dialog>
                                </div>
                                {/* <DropdownMenuItem
                                onSelect={() => {
                                  setKickModalOpen(true);
                                }}
                                className="bg-red-600 rounded"
                              >
                                <Gavel size="16px" className="mr-1" />
                                Ban
                              </DropdownMenuItem> */}
                              </DropdownMenuContent>
                            </DropdownMenu>
                          );
                        }
                      )}
                  </div>
                  {searchQuery && (
                    <>
                      <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow">
                        {Object.values(filteredPlayerList).map(
                          (player: PlayerData, index: number) => {
                            if (!player || !player.ID || !player.Name) return;
                            try {
                              const { displayName, pureName } = cleanPlayerName(
                                player.Name
                              );
                              player.Name = displayName;
                            } catch (error) {
                              console.log(error);
                            }
                            return (
                              <>
                                <DropdownMenu key={player.ID}>
                                  <DropdownMenuTrigger className="rounded text-left p-2 font-semibold bg-black outline-none whitespace-break-spaces">
                                    {player.Name}{" "}
                                    <span
                                      className="float-right text-xs bg-green-600 rounded p-1 bg-opacity-50 text-white font-bold font-inter"
                                      style={{
                                        maxWidth: "250px",
                                      }}
                                    >
                                      ID: {player.ID}
                                    </span>
                                  </DropdownMenuTrigger>
                                  <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
                                    <DropdownMenuLabel
                                      className="font-bold whitespace-break-spaces"
                                      style={{
                                        maxWidth: "250px",
                                      }}
                                    >
                                      [{player.ID}] | {player.Name}
                                    </DropdownMenuLabel>
                                    <DropdownMenuSeparator />
                                    <DropdownMenuItem
                                      className="rounded"
                                      disabled={!sourcePerms.Teleport}
                                      onSelect={() => {
                                        fetchTeleport(player, "Goto");
                                      }}
                                    >
                                      <ArrowLeftRight
                                        size="16px"
                                        className="mr-1"
                                      />{" "}
                                      Goto
                                    </DropdownMenuItem>
                                    <DropdownMenuItem
                                      disabled={!sourcePerms.Teleport}
                                      className="rounded"
                                      onSelect={() => {
                                        fetchTeleport(player, "Bring");
                                      }}
                                    >
                                      <ArrowRightLeft
                                        size="16px"
                                        className="mr-1"
                                      />{" "}
                                      Bring
                                    </DropdownMenuItem>
                                    <DropdownMenuItem
                                      className="rounded"
                                      disabled={!sourcePerms.Freeze}
                                      onSelect={() => {
                                        fetchFreeze(player);
                                      }}
                                    >
                                      {" "}
                                      <Snowflake size="16px" className="mr-1" />
                                      Freeze
                                    </DropdownMenuItem>
                                    <DropdownMenuItem
                                      className="rounded"
                                      disabled={!sourcePerms.Spectate}
                                      onSelect={() => {
                                        fetchSpectate(player);
                                        hideNui();
                                      }}
                                    >
                                      <Glasses size="16px" className="mr-1" />
                                      Spectate
                                    </DropdownMenuItem>
                                    <DropdownMenuItem
                                      disabled={!sourcePerms.Revive}
                                      className="rounded mb-1"
                                      onSelect={() => {
                                        fetchRevive(player);
                                      }}
                                    >
                                      {" "}
                                      <Heart size="16px" className="mr-1" />
                                      Revive
                                    </DropdownMenuItem>
                                    <div className="flex flex-row gap-2">
                                      <Dialog
                                        open={kickModalOpen}
                                        onOpenChange={setKickModalOpen}
                                      >
                                        <DialogTrigger
                                          asChild
                                          disabled={!sourcePerms.Kick}
                                        >
                                          <Button
                                            color="danger"
                                            className=""
                                            style={{
                                              borderColor: "gray",
                                            }}
                                          >
                                            <Zap size="16px" className="mr-1" />{" "}
                                            Kick
                                          </Button>
                                        </DialogTrigger>
                                        <DialogContent className="sm:max-w-[425px] text-white rounded border-none">
                                          <DialogHeader>
                                            <DialogTitle>
                                              [{player.ID}] | {player.Name}?
                                            </DialogTitle>
                                            <DialogDescription>
                                              Input a reason for the kick.
                                            </DialogDescription>
                                          </DialogHeader>
                                          <div className="grid gap-4 py-4">
                                            <div className="grid grid-cols-4 items-center gap-4">
                                              <Label
                                                htmlFor="name"
                                                className="text-right"
                                              >
                                                Reason
                                              </Label>
                                              <Input
                                                id="name"
                                                onChange={(e) => {
                                                  setKickReason(e.target.value);
                                                }}
                                                className="col-span-3"
                                              />
                                            </div>
                                          </div>
                                          <DialogFooter>
                                            <Button
                                              type="submit"
                                              color="danger"
                                              onClick={(e) => {
                                                setKickModalOpen(false);
                                                fetchKickUser(player);
                                                console.log(player);
                                              }}
                                              className="rounded outline-none"
                                            >
                                              Confirm Kick
                                            </Button>
                                          </DialogFooter>
                                        </DialogContent>
                                      </Dialog>

                                      <Dialog
                                        open={banModalOpen}
                                        onOpenChange={setBanModalOpen}
                                      >
                                        <DialogTrigger
                                          asChild
                                          disabled={!sourcePerms.Ban}
                                        >
                                          <Button color="danger">
                                            <Gavel
                                              size="16px"
                                              className="mr-1"
                                            />
                                            Ban
                                          </Button>
                                        </DialogTrigger>
                                        <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                                          <DialogHeader>
                                            <DialogTitle>
                                              [{player.ID}] | {player.Name}?
                                            </DialogTitle>
                                            <DialogDescription>
                                              Input a reason for the ban.
                                            </DialogDescription>
                                          </DialogHeader>
                                          <div className="grid gap-4 py-4">
                                            <div className="flex items-center gap-1">
                                              <Label
                                                htmlFor="name"
                                                className="text-right"
                                              >
                                                Reason
                                              </Label>

                                              <Input
                                                id="name"
                                                onChange={(e) => {
                                                  setBanReason(e.target.value);
                                                }}
                                                className="rounded"
                                              />
                                              <Select
                                                onValueChange={(e: string) => {
                                                  setBanLength(e);
                                                }}
                                                required
                                              >
                                                <SelectTrigger className="w-[180px] outline-none rounded">
                                                  <SelectValue placeholder="Length" />
                                                </SelectTrigger>
                                                <SelectContent
                                                  className="border outline-none rounded font-roboto"
                                                  style={{
                                                    borderColor: "gray",
                                                  }}
                                                >
                                                  <SelectItem value="1 Hour">
                                                    1 Hour
                                                  </SelectItem>
                                                  <SelectItem value="3 Hours">
                                                    3 Hours
                                                  </SelectItem>
                                                  <SelectItem value="6 Hours">
                                                    6 Hours
                                                  </SelectItem>
                                                  <SelectItem value="12 Hours">
                                                    12 Hours
                                                  </SelectItem>
                                                  <SelectItem value="1 Day">
                                                    1 Day
                                                  </SelectItem>
                                                  <SelectItem value="3 Days">
                                                    3 Day
                                                  </SelectItem>
                                                  <SelectItem value="1 Week">
                                                    1 Week
                                                  </SelectItem>
                                                  <SelectItem value="1 Month">
                                                    1 Month
                                                  </SelectItem>
                                                  <SelectItem value="3 Months">
                                                    3 Months
                                                  </SelectItem>
                                                  <SelectItem value="6 Months">
                                                    6 Months
                                                  </SelectItem>
                                                  <SelectItem value="1 Year">
                                                    1 Year
                                                  </SelectItem>
                                                  <SelectItem value="Permanent">
                                                    Permanent
                                                  </SelectItem>
                                                </SelectContent>
                                              </Select>
                                            </div>
                                          </div>
                                          <DialogFooter>
                                            <Button
                                              color="danger"
                                              type="submit"
                                              onClick={(e) => {
                                                setBanModalOpen(false);
                                                fetchBanUser(player);
                                                console.log(player);
                                              }}
                                              className="rounded outline-none"
                                            >
                                              Confirm Ban
                                            </Button>
                                          </DialogFooter>
                                        </DialogContent>
                                      </Dialog>
                                    </div>
                                    {/* <DropdownMenuItem
                                onSelect={() => {
                                  setKickModalOpen(true);
                                }}
                                className="bg-red-600 rounded"
                              >
                                <Gavel size="16px" className="mr-1" />
                                Ban
                              </DropdownMenuItem> */}
                                  </DropdownMenuContent>
                                </DropdownMenu>
                              </>
                            );
                          }
                        )}
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
                  <div className="grid grid-cols-4 gap-5 mt-2 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow">
                    {!cacheSearchQuery &&
                      Object.values(cachedPlayers).map(
                        (player: PlayerData, index: number) => {
                          if (!player || !player.ID || !player.Name) {
                            return;
                          }
                          try {
                            const { displayName, pureName } = cleanPlayerName(
                              player.Name
                            );
                            player.Name = displayName;
                          } catch (error) {
                            console.log(error);
                          }
                          return (
                            <>
                              <DropdownMenu key={index}>
                                <DropdownMenuTrigger className="rounded text-left p-2 font-semibold bg-black outline-none text-white">
                                  {player.Name}
                                  <span
                                    className="float-right text-xs bg-red-500 rounded p-1 bg-opacity-50 text-white font-bold font-inter whitespace-break-spaces"
                                    style={{
                                      maxWidth: "250px",
                                    }}
                                  >
                                    Old ID: {player.ID}
                                  </span>
                                </DropdownMenuTrigger>
                                <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
                                  <DropdownMenuLabel
                                    className="font-bold whitespace-break-spaces"
                                    style={{
                                      maxWidth: "250px",
                                    }}
                                  >
                                    [{player.ID}] | {player.Name}
                                  </DropdownMenuLabel>
                                  <DropdownMenuSeparator />
                                  {/* <DropdownMenuItem className="rounded mb-1">
                                <Fingerprint size="16px" className="mr-1" />{" "}
                                Identifiers
                              </DropdownMenuItem> */}
                                  <AlertDialog>
                                    <AlertDialogTrigger
                                      className="rounded mb-1 flex justify-center items-center font-inter w-full p-1 font-semibold text-sm"
                                      disabled={!sourcePerms.Menu}
                                    >
                                      {" "}
                                      <Fingerprint
                                        size="16px"
                                        className="mr-1"
                                      />{" "}
                                      Identifiers
                                    </AlertDialogTrigger>
                                    <AlertDialogContent className="border-none rounded text-white w-full p-3">
                                      <AlertDialogHeader>
                                        <AlertDialogTitle>
                                          [{player.ID}] | {player.Name}
                                        </AlertDialogTitle>
                                        <AlertDialogDescription>
                                          <div>
                                            <p className="font-inter text-lg text-white mt-3 uppercase font-bold">
                                              Identifier
                                            </p>
                                            {player.Identifiers.map(
                                              (
                                                identifier: any,
                                                index: number
                                              ) => (
                                                <>
                                                  <div className="flex flex-col gap-2 rounded text-xs">
                                                    <p>{identifier}</p>
                                                  </div>
                                                </>
                                              )
                                            )}
                                          </div>
                                          <div className="mt-10">
                                            <p className="font-inter text-lg text-white mb-2 uppercase font-bold">
                                              Hardware ID
                                            </p>
                                            {player.HWIDS.map(
                                              (hwid: any, index: number) => (
                                                <>
                                                  <div className="flex flex-col gap-2 rounded text-xs">
                                                    <p>{hwid}</p>
                                                  </div>
                                                </>
                                              )
                                            )}
                                          </div>
                                        </AlertDialogDescription>
                                      </AlertDialogHeader>
                                      <AlertDialogFooter>
                                        {/* <AlertDialogCancel className="rounded">
                                          Cancel
                                        </AlertDialogCancel> */}
                                        <AlertDialogAction className="rounded">
                                          Close
                                        </AlertDialogAction>
                                      </AlertDialogFooter>
                                    </AlertDialogContent>
                                  </AlertDialog>
                                  <Dialog
                                    open={banModalOpen}
                                    onOpenChange={setBanModalOpen}
                                  >
                                    <DialogTrigger
                                      asChild
                                      disabled={!sourcePerms["Offline Ban"]}
                                    >
                                      <Button
                                        color="danger"
                                        className="mt-1 w-full "
                                      >
                                        <Gavel size="16px" className="mr-1" />
                                        Offline Ban
                                      </Button>
                                    </DialogTrigger>
                                    <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                                      <DialogHeader>
                                        <DialogTitle>
                                          [{player.ID}] | {player.Name}?
                                        </DialogTitle>
                                        <DialogDescription>
                                          Input a reason for the ban.
                                        </DialogDescription>
                                      </DialogHeader>
                                      <div className="grid gap-4 py-4">
                                        <div className="flex items-center gap-1">
                                          <Label
                                            htmlFor="name"
                                            className="text-right"
                                          >
                                            Reason
                                          </Label>

                                          <Input
                                            id="name"
                                            onChange={(e) => {
                                              setOffineBanReason(
                                                e.target.value
                                              );
                                            }}
                                            className="rounded"
                                          />
                                          <Select
                                            onValueChange={(e: string) => {
                                              setOfflineBanLength(e);
                                            }}
                                            required
                                          >
                                            <SelectTrigger className="w-[180px] outline-none rounded">
                                              <SelectValue placeholder="Length" />
                                            </SelectTrigger>
                                            <SelectContent
                                              className="border outline-none rounded font-roboto"
                                              style={{
                                                borderColor: "gray",
                                              }}
                                            >
                                              <SelectItem value="1 Hour">
                                                1 Hour
                                              </SelectItem>
                                              <SelectItem value="3 Hours">
                                                3 Hours
                                              </SelectItem>
                                              <SelectItem value="6 Hours">
                                                6 Hours
                                              </SelectItem>
                                              <SelectItem value="12 Hours">
                                                12 Hours
                                              </SelectItem>
                                              <SelectItem value="1 Day">
                                                1 Day
                                              </SelectItem>
                                              <SelectItem value="3 Days">
                                                3 Day
                                              </SelectItem>
                                              <SelectItem value="1 Week">
                                                1 Week
                                              </SelectItem>
                                              <SelectItem value="1 Month">
                                                1 Month
                                              </SelectItem>
                                              <SelectItem value="3 Months">
                                                3 Months
                                              </SelectItem>
                                              <SelectItem value="6 Months">
                                                6 Months
                                              </SelectItem>
                                              <SelectItem value="1 Year">
                                                1 Year
                                              </SelectItem>
                                              <SelectItem value="Permanent">
                                                Permanent
                                              </SelectItem>
                                            </SelectContent>
                                          </Select>
                                        </div>
                                      </div>
                                      <DialogFooter>
                                        <Button
                                          color="danger"
                                          type="submit"
                                          onClick={(e) => {
                                            setBanModalOpen(false);
                                            fetchOfflineBanUser(player);
                                          }}
                                          className="rounded outline-none"
                                        >
                                          Confirm Ban
                                        </Button>
                                      </DialogFooter>
                                    </DialogContent>
                                  </Dialog>
                                  {/* <DropdownMenuItem
                                onSelect={() => {
                                  setKickModalOpen(true);
                                }}
                                className="bg-red-600 rounded"
                              >
                                <Gavel size="16px" className="mr-1" />
                                Ban
                              </DropdownMenuItem> */}
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </>
                          );
                        }
                      )}
                    {cacheSearchQuery &&
                      Object.values(filteredCacheList).map(
                        (player: PlayerData, index: number) => {
                          if (!player || !player.ID || !player.Name) return;
                          try {
                            const { displayName, pureName } = cleanPlayerName(
                              player.Name
                            );
                            player.Name = displayName;
                          } catch (error) {
                            console.log(error);
                          }
                          return (
                            <>
                              <DropdownMenu key={index}>
                                <DropdownMenuTrigger
                                  className="rounded text-left p-2 font-semibold bg-black outline-none text-white break-words whitespace-break-spaces"
                                  style={{
                                    maxWidth: "250px",
                                  }}
                                >
                                  {player.Name}
                                  <span className="float-right text-xs bg-red-500 rounded p-1 bg-opacity-50 text-white font-bold font-inter">
                                    Old ID: {player.ID}
                                  </span>
                                </DropdownMenuTrigger>
                                <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
                                  <DropdownMenuLabel
                                    className="font-bold whitespace-break-spaces"
                                    style={{
                                      maxWidth: "250px",
                                    }}
                                  >
                                    [{player.ID}] | {player.Name}
                                  </DropdownMenuLabel>
                                  <DropdownMenuSeparator />
                                  {/* <DropdownMenuItem className="rounded mb-1">
                                <Fingerprint size="16px" className="mr-1" />{" "}
                                Identifiers
                              </DropdownMenuItem> */}
                                  <AlertDialog>
                                    <AlertDialogTrigger
                                      className="rounded mb-1 flex justify-center items-center font-inter w-full p-1 font-semibold text-sm"
                                      disabled={!sourcePerms.Menu}
                                    >
                                      {" "}
                                      <Fingerprint
                                        size="16px"
                                        className="mr-1"
                                      />{" "}
                                      Identifiers
                                    </AlertDialogTrigger>
                                    <AlertDialogContent className="border-none rounded text-white w-full p-3">
                                      <AlertDialogHeader>
                                        <AlertDialogTitle>
                                          [{player.ID}] | {player.Name}
                                        </AlertDialogTitle>
                                        <AlertDialogDescription>
                                          <div>
                                            <p className="font-inter text-lg text-white mt-3 uppercase font-bold">
                                              Identifier
                                            </p>
                                            {player.Identifiers.map(
                                              (
                                                identifier: any,
                                                index: number
                                              ) => (
                                                <>
                                                  <div className="flex flex-col gap-2 rounded text-xs">
                                                    <p>{identifier}</p>
                                                  </div>
                                                </>
                                              )
                                            )}
                                          </div>
                                          <div className="mt-10">
                                            <p className="font-inter text-lg text-white mb-2 uppercase font-bold">
                                              Hardware ID
                                            </p>
                                            {player.HWIDS.map(
                                              (hwid: any, index: number) => (
                                                <>
                                                  <div className="flex flex-col gap-2 rounded text-xs">
                                                    <p>{hwid}</p>
                                                  </div>
                                                </>
                                              )
                                            )}
                                          </div>
                                        </AlertDialogDescription>
                                      </AlertDialogHeader>
                                      <AlertDialogFooter>
                                        {/* <AlertDialogCancel className="rounded">
                                          Cancel
                                        </AlertDialogCancel> */}
                                        <AlertDialogAction className="rounded">
                                          Close
                                        </AlertDialogAction>
                                      </AlertDialogFooter>
                                    </AlertDialogContent>
                                  </AlertDialog>
                                  <Dialog
                                    open={banModalOpen}
                                    onOpenChange={setBanModalOpen}
                                  >
                                    <DialogTrigger
                                      asChild
                                      disabled={!sourcePerms["Offline Ban"]}
                                    >
                                      <Button
                                        color="danger"
                                        className="mt-1 w-full "
                                      >
                                        <Gavel size="16px" className="mr-1" />
                                        Offline Ban
                                      </Button>
                                    </DialogTrigger>
                                    <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                                      <DialogHeader>
                                        <DialogTitle>
                                          [{player.ID}] | {player.Name}?
                                        </DialogTitle>
                                        <DialogDescription>
                                          Input a reason for the ban.
                                        </DialogDescription>
                                      </DialogHeader>
                                      <div className="grid gap-4 py-4">
                                        <div className="flex items-center gap-1">
                                          <Label
                                            htmlFor="name"
                                            className="text-right"
                                          >
                                            Reason
                                          </Label>

                                          <Input
                                            id="name"
                                            onChange={(e) => {
                                              setOffineBanReason(
                                                e.target.value
                                              );
                                            }}
                                            className="rounded"
                                          />
                                          <Select
                                            onValueChange={(e: string) => {
                                              setOfflineBanLength(e);
                                            }}
                                            required
                                          >
                                            <SelectTrigger className="w-[180px] outline-none rounded">
                                              <SelectValue placeholder="Length" />
                                            </SelectTrigger>
                                            <SelectContent
                                              className="border outline-none rounded font-roboto"
                                              style={{
                                                borderColor: "gray",
                                              }}
                                            >
                                              <SelectItem value="6 Hours">
                                                6 Hours
                                              </SelectItem>
                                              <SelectItem value="12 Hours">
                                                12 Hours
                                              </SelectItem>
                                              <SelectItem value="3 Days">
                                                3 Day
                                              </SelectItem>
                                              <SelectItem value="1 Week">
                                                1 Week
                                              </SelectItem>
                                              <SelectItem value="1 Month">
                                                1 Month
                                              </SelectItem>
                                              <SelectItem value="3 Months">
                                                3 Months
                                              </SelectItem>
                                              <SelectItem value="6 Months">
                                                6 Months
                                              </SelectItem>
                                              <SelectItem value="1 Year">
                                                1 Year
                                              </SelectItem>
                                              <SelectItem value="Permanent">
                                                Permanent
                                              </SelectItem>
                                            </SelectContent>
                                          </Select>
                                        </div>
                                      </div>
                                      <DialogFooter>
                                        <Button
                                          color="danger"
                                          type="submit"
                                          onClick={(e) => {
                                            setBanModalOpen(false);
                                            fetchOfflineBanUser(player);
                                          }}
                                          className="rounded outline-none"
                                        >
                                          Confirm Ban
                                        </Button>
                                      </DialogFooter>
                                    </DialogContent>
                                  </Dialog>
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </>
                          );
                        }
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
