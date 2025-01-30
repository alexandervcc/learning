import { ApiProperty } from '@nestjs/swagger';

export class AppReqDto {
  @ApiProperty({
    description: 'Name of the user',
    type: String,
    example: 'Mijotron',
    required: true,
  })
  name: string;
}

export class AppResDto {
  @ApiProperty({
    description: 'Message to the user',
    type: String,
  })
  message: string;
}
