import React, { useState } from "react";
import "./Main.css";
import { fetchNui } from "../utils/fetchNui";
import cleanPlayerName from "@/utils/cleanPlayerName";
import {
  ArrowLeftRight,
  ArrowRightLeft,
  Fingerprint,
  Gavel,
  Glasses,
  Heart,
  Snowflake,
  Zap,
} from "lucide-react";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

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
} from "./ui/alert-dialog";

type PlayerData = {
  name: string | null;
  id: number | null;
  identifiers: any;
  tokens: any;
};

interface Props {
  playerList: any;
  sourcePerms: any;
  cached: boolean;
}
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

const PlayerList: React.FC<Props> = ({ playerList, cached, sourcePerms }) => {
  const [kickModalOpen, setKickModalOpen] = useState(false);
  const [banModalOpen, setBanModalOpen] = useState(false);
  const { toast } = useToast();
  const [banData, setBanData] = useState<BanData>({
    target_id: 0,
    length: "",
    reason: "",
  });
  const [kickData, setKickData] = useState<KickData>({
    target_id: 0,
    reason: "",
  });
  const [banLength, setBanLength] = useState("");
  const [banReason, setBanReason] = useState("");
  const [kickReason, setKickReason] = useState("");

  const hideNui = () => {
    setBanData({
      target_id: 0,
      length: "",
      reason: "",
    });
    setBanLength("");
    setBanReason("");
    setKickReason("");
    setKickData({
      target_id: 0,
      reason: "",
    });
    fetchNui("hideFrame");
  };

  const fetchOfflineBanUser = (player: PlayerData) => {
    if (!banReason || !banLength) {
      toast({
        variant: "destructive",
        description: "Ban Reason or Length is not specified.",
        className: "rounded font-roboto",
      });
      return;
    }

    const offlineBanData = {
      length: banLength,
      reason: banReason,
      identifiers: player.identifiers,
      playerName: player.name,
      tokens: player.tokens,
    };

    fetchNui("vadmin:client:offlineban", offlineBanData);
    setBanLength("");
    setBanReason("");
    hideNui();
  };

  const fetchBanUser = (player: any) => {
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
    banData.target_id = player.id;

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

  // const fetchRevive = (player: any) => {
  //   fetchNui("vadmin:client:rev", player);
  // };

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
    kickData.target_id = player.id;

    fetchNui("vadmin:nui_cb:kick", kickData);

    setKickReason("");
    setKickData({
      target_id: 0,
      reason: "",
    });
    hideNui();
  };

  return (
    <>
      <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded boxshadow text-white">
        {Object.values(playerList).map((player: any) => {
          if (!player) return;
          try {
            const { displayName, pureName } = cleanPlayerName(player.name);
            player.name = displayName;
          } catch (error) {
            console.log(error);
          }
          return (
            <DropdownMenu key={player.id}>
              <DropdownMenuTrigger className="rounded text-left p-2 font-semibold bg-black outline-none whitespace-break-spaces">
                {player.name}{" "}
                <span
                  className={`float-right text-xs ${
                    cached ? "bg-red-600" : "bg-green-600"
                  } rounded p-1 bg-opacity-50 text-white font-bold font-inter`}
                  style={{
                    maxWidth: "250px",
                  }}
                >
                  ID: {player.id}
                </span>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
                <DropdownMenuLabel
                  className="font-bold whitespace-break-spaces"
                  style={{
                    maxWidth: "250px",
                  }}
                >
                  [{player.id}] | {player.name}
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <AlertDialog>
                  <AlertDialogTrigger
                    className="w-full mb-1 flex cursor-default select-none justify-start items-center rounded px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 border-none hover:bg-accent"
                    disabled={!sourcePerms.Menu}
                  >
                    {" "}
                    <Fingerprint size="16px" className="mr-1" /> Info
                  </AlertDialogTrigger>
                  <AlertDialogContent className="border-none rounded text-white w-full p-3">
                    <AlertDialogHeader>
                      <AlertDialogTitle>
                        [{player.id}] | {player.name}
                      </AlertDialogTitle>
                      <AlertDialogDescription>
                        <div>
                          <p className="font-inter text-lg text-white mt-3 uppercase font-bold">
                            Identifiers
                          </p>
                          {player.identifiers.map(
                            (identifier: any, index: number) => (
                              <>
                                <div
                                  className="flex flex-col gap-2 rounded text-xs"
                                  key={index}
                                >
                                  <p>{identifier}</p>
                                </div>
                              </>
                            )
                          )}
                        </div>
                        <div className="mt-10">
                          <p className="font-inter text-lg text-white mb-2 uppercase font-bold">
                            Hardware ID's
                          </p>
                          {player.tokens.map((token: any, index: number) => (
                            <>
                              <div
                                className="flex flex-col gap-2 rounded text-xs"
                                key={index}
                              >
                                <p>{token}</p>
                              </div>
                            </>
                          ))}
                        </div>
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogAction className="rounded">
                        Close
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
                {!cached && (
                  <>
                    <DropdownMenuItem
                      className="rounded mb-1"
                      disabled={!sourcePerms.Teleport}
                      onSelect={() => {
                        fetchTeleport(player, "Goto");
                      }}
                    >
                      <ArrowLeftRight size="16px" className="mr-1" /> Goto
                    </DropdownMenuItem>

                    <DropdownMenuItem
                      disabled={!sourcePerms.Teleport}
                      className="rounded"
                      onSelect={() => {
                        fetchTeleport(player, "Bring");
                      }}
                    >
                      <ArrowRightLeft size="16px" className="mr-1" /> Bring
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
                      className="rounded mb-1"
                      disabled={!sourcePerms.Spectate}
                      onSelect={() => {
                        fetchSpectate(player);
                        hideNui();
                      }}
                    >
                      <Glasses size="16px" className="mr-1" />
                      Spectate
                    </DropdownMenuItem>
                  </>
                )}
                <div className="flex flex-row gap-2">
                  {!cached && (
                    <>
                      <Dialog
                        open={kickModalOpen}
                        onOpenChange={setKickModalOpen}
                      >
                        <DialogTrigger asChild disabled={!sourcePerms.Kick}>
                          <Button
                            color="danger"
                            className=""
                            style={{
                              borderColor: "gray",
                            }}
                          >
                            <Zap size="16px" className="mr-1" /> Kick
                          </Button>
                        </DialogTrigger>
                        <DialogContent className="sm:max-w-[425px] text-white rounded border-none">
                          <DialogHeader>
                            <DialogTitle>
                              [{player.id}] | {player.name}?
                            </DialogTitle>
                            <DialogDescription>
                              Input a reason for the kick.
                            </DialogDescription>
                          </DialogHeader>
                          <div className="grid gap-4 py-4">
                            <div className="grid grid-cols-4 items-center gap-4">
                              <Label htmlFor="name" className="text-right">
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
                              }}
                              className="rounded outline-none"
                            >
                              Confirm Kick
                            </Button>
                          </DialogFooter>
                        </DialogContent>
                      </Dialog>
                    </>
                  )}

                  <Dialog open={banModalOpen} onOpenChange={setBanModalOpen}>
                    <DialogTrigger
                      asChild
                      disabled={!sourcePerms.Ban}
                      className={`${cached ? "w-full" : ""}`}
                    >
                      <Button color="danger">
                        <Gavel size="16px" className="mr-1" />
                        {!cached ? "Ban" : "Offline Ban"}
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[525px] text-white rounded border-none">
                      <DialogHeader>
                        <DialogTitle>
                          [{player.id}] | {player.name}?
                        </DialogTitle>
                        <DialogDescription>
                          Input a reason for the ban.
                        </DialogDescription>
                      </DialogHeader>
                      <div className="grid gap-4 py-4">
                        <div className="flex items-center gap-1">
                          <Label htmlFor="name" className="text-right">
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
                              <SelectItem value="1 Hour">1 Hour</SelectItem>
                              <SelectItem value="3 Hours">3 Hours</SelectItem>
                              <SelectItem value="6 Hours">6 Hours</SelectItem>
                              <SelectItem value="12 Hours">12 Hours</SelectItem>
                              <SelectItem value="1 Day">1 Day</SelectItem>
                              <SelectItem value="3 Days">3 Day</SelectItem>
                              <SelectItem value="1 Week">1 Week</SelectItem>
                              <SelectItem value="1 Month">1 Month</SelectItem>
                              <SelectItem value="3 Months">3 Months</SelectItem>
                              <SelectItem value="6 Months">6 Months</SelectItem>
                              <SelectItem value="1 Year">1 Year</SelectItem>
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
                            if (cached) {
                              fetchOfflineBanUser(player);
                              return;
                            }
                            fetchBanUser(player);
                          }}
                          className="rounded outline-none"
                        >
                          Confirm Ban
                        </Button>
                      </DialogFooter>
                    </DialogContent>
                  </Dialog>
                </div>
              </DropdownMenuContent>
            </DropdownMenu>
          );
        })}
      </div>
    </>
  );
};

export default PlayerList;
