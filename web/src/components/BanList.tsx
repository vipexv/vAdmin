import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Pagination } from "@mantine/core";
import Button from "@mui/joy/Button";
import { CircleSlash, Fingerprint, ShieldOff } from "lucide-react";
import React, { useState } from "react";
import { fetchNui } from "../utils/fetchNui";
import "./Main.css";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "./ui/alert-dialog";

interface PlayerData {
  name: string | null;
  id: number | null;
  identifiers: any;
  tokens: any;
  isStaff: boolean;
}

interface Props {
  banList: Ban[];
  sourcePerms: any;
}
interface BanData {
  target_id: number;
  reason: string;
  length: string;
}
interface OfflineBanData {
  reason: string;
  length: string;
  identifiers: any | null;
  playerName: string | null;
  tokens: any | null;
}

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

function chunk<T>(array: T[], size: number): T[][] {
  if (!array.length) {
    return [];
  }
  const head = array.slice(0, size);
  const tail = array.slice(size);
  return [head, ...chunk(tail, size)];
}

const BanList: React.FC<Props> = ({ banList, sourcePerms }) => {
  const [activePage, setPage] = useState(1);
  const [unbanModalOpen, setUnbanModalOpen] = useState(false);
  const data = chunk(banList, 25);

  const fetchUnbanUser = (player: Ban) => {
    fetchNui("vadmin:nui_cb:unban:global", player);
    fetchNui("hideFrame");
  };

  const items = data[activePage - 1]?.map((player: Ban, index: number) => (
    <>
      <DropdownMenu key={index}>
        <DropdownMenuTrigger className="rounded max-h-[40px] flex items-center justify-between text-left p-2 font-semibold bg-black outline-none whitespace-break-spaces">
          {player.playerName}{" "}
          <span
            className={`float-right text-xs bg-green-600
          rounded p-1 bg-opacity-50 text-white font-bold font-inter`}
            style={{
              maxWidth: "250px",
            }}
          >
            {player.uuid}
          </span>
        </DropdownMenuTrigger>
        <DropdownMenuContent className="border-none font-semibold rounded coolstuff font-inter">
          <DropdownMenuLabel
            className="font-bold whitespace-break-spaces"
            style={{
              maxWidth: "250px",
            }}
          >
            [{player.uuid}] | {player.playerName}
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          <AlertDialog>
            <AlertDialogTrigger
              className="w-full mb-2 flex cursor-default select-none justify-start items-center rounded px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 border-none hover:bg-accent"
              disabled={!sourcePerms.Menu}
            >
              <Fingerprint size="16px" className="mr-1" /> Ban Info
            </AlertDialogTrigger>
            <AlertDialogContent className="border-none rounded text-white w-full p-3">
              <AlertDialogHeader>
                <AlertDialogTitle>
                  Ban ID: {player.uuid} | {player.playerName}
                </AlertDialogTitle>
                <AlertDialogDescription>
                  <div>
                    <h1 className="font-inter text-lg font-bold text-white">
                      Info
                    </h1>
                    <p>Banned by: {player.StaffMember}</p>
                    <p>Ban Reason: {player.Reason}</p>
                    <p>Ban Length {player.LengthString}</p>
                    <p>Unban Date: {player.UnbanDate}</p>
                    <p>Ban ID: {player.uuid}</p>
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
                <AlertDialogAction className="rounded">Close</AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
          <Dialog open={unbanModalOpen} onOpenChange={setUnbanModalOpen}>
            <DialogTrigger asChild disabled={!sourcePerms.Kick}>
              <Button
                color="danger"
                className="w-full rounded-[2px]"
                disabled={!sourcePerms["Unban"]}
                style={{
                  borderColor: "gray",
                }}
              >
                <ShieldOff size="16px" className="mr-1" /> Unban
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px] text-white rounded border-none">
              <DialogHeader>
                <DialogTitle>
                  Ban ID: {player.uuid} | {player.playerName}?
                </DialogTitle>
                <DialogDescription>
                  Are you sure you want to unban this player?
                </DialogDescription>
              </DialogHeader>
              <DialogFooter>
                <Button
                  type="submit"
                  color="danger"
                  onClick={(e) => {
                    setUnbanModalOpen(false);
                    fetchUnbanUser(player);
                  }}
                  className="rounded outline-none"
                >
                  Confirm
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
          <div className="flex flex-row gap-2"></div>
        </DropdownMenuContent>
      </DropdownMenu>
    </>
  ));

  return (
    <>
      {items && items.length > 0 ? (
        <>
          <div className="grid grid-cols-4 gap-5 mt-1 px-1 overflow-y-scroll overflow-x-hidden max-h-[60vh] w-[50vw] z-20 rounded">
            {items}
          </div>
          <div className="flex justify-center items-center">
            <Pagination
              total={data.length}
              value={activePage}
              onChange={setPage}
              mt="sm"
            />
          </div>
        </>
      ) : (
        <>
          <div className="flex justify-center items-center gap-1 font-inter font-bold p-2 rounded">
            <CircleSlash size={16} strokeWidth={2.25} /> Empty
          </div>
        </>
      )}
    </>
  );
};

export default BanList;
