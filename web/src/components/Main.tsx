import { motion } from "framer-motion";
import React, { useEffect, useRef, useState } from "react";
import BanList from "./BanList";
import PlayerList from "./PlayerList";

// Other React-related imports

import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";

// Other utility functions

import {
  CarFront,
  Cross,
  Hammer,
  MoreHorizontal,
  ShieldCheck,
  ShieldHalf,
  ShieldX,
  UserSquare,
  UserX2,
  Users,
  X,
} from "lucide-react";

// Other component imports

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { useToast } from "@/components/ui/use-toast";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import Button from "@mui/joy/Button";

import { Label } from "@/components/ui/label";
import Input from "@mui/joy/Input";

interface Ban {
  tokens: string[];
  Length: number;
  StaffMember: string;
  Reason: string;
  LengthString: string;
  banDate: string;
  playerName: string;
  uuid: string;
  UnbanDate: string;
  identifiers: string[];
}

type Tabs = {
  Players: boolean;
  SelfOptions: boolean;
  Utilities: boolean;
  Cache: boolean;
  BanList: boolean;
};

type PlayerMenuPermissionV2 = {
  [key: string]: boolean;
};

type selectedOptions = {
  health: boolean;
  armor: boolean;
  playerNames: boolean;
  carWipe: boolean;
  clearChat: boolean;
};

type PlayerData = {
  name: string;
  id: number;
  identifiers: string[];
  tokens: string[];
  isStaff: boolean;
};

const initialPlayerMenuPermissions: PlayerMenuPermissionV2 = {
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
};

const initialTabsState: Tabs = {
  Players: true,
  SelfOptions: false,
  Utilities: false,
  Cache: false,
  BanList: false,
};

const initialSelectedOptions: selectedOptions = {
  health: false,
  armor: false,
  playerNames: false,
  carWipe: false,
  clearChat: false,
};
// #646cff

const setupDebugData = () => {
  debugData([
    {
      action: "setVisible",
      data: true,
    },
  ]);

  const initialDebugPerms: PlayerMenuPermissionV2 = {
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

  const examplePlayerData = Array.from({ length: 2 }, (_, index) => ({
    name: `Test Dummy ${index + 1}`,
    id: index + 1,
    identifiers: [
      "license:213asdad",
      "xbl:213asdad",
      "live:213asdad",
      "discord:213asdad",
      "fivem:213asdad",
      "license2:213asdad",
    ],
    tokens: [
      "3:21312313124asda",
      "2:21312313124asda",
      "5:21312313124asda",
      "4:21312313124asda",
      "4:21312313124asda",
      "4:21312313124asda",
    ],
    isStaff: true,
  }));

  debugData([
    {
      action: "nui:adminperms",
      data: initialDebugPerms,
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
};

setupDebugData();

const Main: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [sourcePerms, setSourcePerms] = useState<PlayerMenuPermissionV2>(
    initialPlayerMenuPermissions
  );
  const searchRef = useRef<HTMLInputElement>(null);
  const [currentTab, setCurrentTab] = useState<Tabs>(initialTabsState);
  const { toast } = useToast();
  const [players, setPlayers] = useState<PlayerData[]>([]);
  const [banID, setBanID] = useState("");
  const [cachedPlayers, setCachedPlayers] = useState<PlayerData[]>([]);
  const [filteredPlayerList, setFilteredPlayerList] = useState<PlayerData[]>(
    []
  );
  const [banListSearchQuery, setBanListSearchQuery] = useState("");
  const [filteredCacheList, setFilteredCacheList] = useState<PlayerData[]>([]);
  const [selectedOptions, setSelectedOptions] = useState<selectedOptions>(
    initialSelectedOptions
  );
  const [filteredBanlist, setFilteredBanlist] = useState<Ban[]>([]);

  const [banModalOpen, setBanModalOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [cacheSearchQuery, setCacheSearchQuery] = useState<string>("");
  const [activeBans, setActiveBans] = useState<Ban[]>([]);

  useNuiEvent("nui:state:activeBans", setActiveBans);

  // const activeBans: Ban[] = Array.from({ length: 100 }, (_, index) => ({
  //   tokens: [
  //     "2:91b99996378cd5b16ec214d54e850d5f265524a84620671ee34d594bdb154e65",
  //     "5:f49c3a5268773ac5d8b26a350c9015c11bef14635cddf6ea6ede03bcbfd2a835",
  //     "3:2d24e6be9b493d5d151bd09d80bb82a85e0de0202d7ea3e641316002605c5350",
  //     "4:cc61f15f255b3638a9569c32bb4e16f5a7a80ba12d4bc5eec5fea71a08a95d92",
  //     "4:91079bd7b386e9ff7ddb12280bbc2d69c3508bf9ca6eac16855ab50c8d149ea2",
  //     "4:454ff596785cb8a5ae9d9661cc47163ee569a159e3ae94540a8e983ae2d2f3c9",
  //   ],
  //   Length: 1703274130,
  //   StaffMember: "vipex",
  //   Reason: "Not cool!",
  //   LengthString: "6 Hours",
  //   banDate: "12/22/23",
  //   playerName: `Test Ban ${index}`,
  //   uuid: `A${index}`,
  //   UnbanDate: "12/22/23 (20:42:10)",
  //   identifiers: [
  //     "license:6c5a04a27880f9ef14f177cd52b495d6d9517187",
  //     "xbl:2535413463113628",
  //     "live:844425900550524",
  //     "discord:470311257589809152",
  //     "fivem:1124792",
  //     "license2:6c5a04a27880f9ef14f177cd52b495d6d9517187",
  //   ],
  // }));

  useNuiEvent<PlayerData[]>("nui:plist", setPlayers);
  useNuiEvent<PlayerMenuPermissionV2>("nui:adminperms", setSourcePerms);
  useNuiEvent<PlayerData[]>("nui:clist", setCachedPlayers);
  useNuiEvent<boolean>("setVisible", setVisible);

  useNuiEvent("nui:notify", (message: string) => {
    toast({
      variant: "default",
      description: message,
      className: "rounded font-inter",
    });
  });

  useEffect(() => {
    const filterPlayers = (data: PlayerData[], query: string) => {
      return data
        ? Object.values(data).filter((player) => {
            if (!player || !player.id || !player.name) return;
            const playerId = player.id?.toString().toLowerCase();
            return (
              player.name.toLowerCase().includes(query) ||
              playerId.includes(query)
            );
          })
        : [];
    };

    setFilteredPlayerList(filterPlayers(players, searchQuery));
  }, [searchQuery, players]);

  useEffect(() => {
    const filterBanList = (data: Ban[], query: string) => {
      return data
        ? Object.values(data).filter((player) => {
            if (!player) return console.log("hey");
            const searchValue = query.toLowerCase();
            const playerId = player.uuid?.toString().toLowerCase();
            return (
              player.playerName.toLowerCase().includes(searchValue) ||
              playerId.includes(searchValue)
            );
          })
        : [];
    };

    setFilteredBanlist(filterBanList(activeBans, banListSearchQuery));
    console.log(filteredBanlist);
  }, [banListSearchQuery]);

  useEffect(() => {
    const filterCachedPlayers = (data: PlayerData[], query: string) => {
      return data
        ? Object.values(data).filter((player) => {
            if (!player || !player.id || !player.name) return;
            const playerId = player.id?.toString().toLowerCase();
            return (
              player.name.toLowerCase().includes(query) ||
              playerId.includes(query)
            );
          })
        : [];
    };

    setFilteredCacheList(filterCachedPlayers(cachedPlayers, cacheSearchQuery));
  }, [cacheSearchQuery, cachedPlayers]);

  useEffect(() => {
    searchRef.current?.focus();
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        if (!isEnvBrowser()) {
          setCurrentTab(initialTabsState);
          fetchNui("hideFrame");
        } else setVisible(!visible);
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => window.removeEventListener("keydown", keyHandler);
  }, [visible]);

  const fetchClient = () => {
    fetchNui("vadmin:client:options", selectedOptions);
    setSelectedOptions(initialSelectedOptions);
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

  const hideNui = () => {
    setCurrentTab(initialTabsState);
    fetchNui("hideFrame");
  };

  return (
    <>
      {!!visible && (
        <>
          <div className="w-screen h-screen flex flex-col gap-2 justify-center items-center">
            <motion.div
              className="bg-[#1a1a1a] border bg-opacity-80 px-5 py-2 border-[#1a1a1a] rounded boxshadow"
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
                <button
                  className={`rounded transition p-2 flex justify-center items-center active:scale-90 ${
                    currentTab.BanList ? "bg-slate-700 bg-opacity-50" : ""
                  }`}
                  style={{
                    borderColor: "#059669",
                  }}
                  onClick={() =>
                    setCurrentTab({
                      Players: false,
                      SelfOptions: false,
                      Utilities: false,
                      BanList: true,
                      Cache: false,
                    })
                  }
                >
                  <Hammer size={"16px"} className="mr-1" /> Ban List
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
                      ref={searchRef}
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value);
                      }}
                    />
                  </div>
                  <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60dvh] w-[50vw] z-20 rounded">
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
                      <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60dvh] w-[50vw] z-20 rounded">
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
              ) : currentTab.BanList ? (
                <>
                  <div className="flex justify-end items-center px-2 py-2">
                    <input
                      type="text"
                      className="outline-none w-fit float-right py-1 px-2 mb-2 bg-transparent rounded font-inter focus:-translate-y-1 transition"
                      style={{
                        border: "2px solid #059669",
                        borderColor: "#059669",
                      }}
                      placeholder="Search..."
                      // ref={searchRef}
                      value={banListSearchQuery}
                      onChange={(e) => {
                        setBanListSearchQuery(e.target.value);
                      }}
                    />
                  </div>
                  {!banListSearchQuery ? (
                    <BanList banList={activeBans} sourcePerms={sourcePerms} />
                  ) : (
                    <>
                      <BanList
                        banList={filteredBanlist}
                        sourcePerms={sourcePerms}
                      />
                    </>
                  )}
                </>
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
                  <div className="grid grid-cols-4 gap-5 mt-2 px-1 overflow-y-scroll overflow-x-hidden min-max-h-[60dvh] w-[50vw] z-20 rounded text-white">
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
