import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class GenerateWorkspaceDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @MaxLength(500)
  prompt!: string;
}
