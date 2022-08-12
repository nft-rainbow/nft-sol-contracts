export declare function checkRole(
  url: string,
  address: string,
  role: string,
  user: string
): Promise<boolean>;

export declare function tryMintTo(
  url: string,
  address: string,
  user: string
): void;
