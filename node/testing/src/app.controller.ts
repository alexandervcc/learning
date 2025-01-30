import { Body, Controller, Post } from '@nestjs/common';
import { AppService } from './app.service';
import { AppReqDto, AppResDto } from './dto/app.dto';
import { ApiResponse } from '@nestjs/swagger';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Post()
  @ApiResponse({
    status: 200,
    description: 'The message was successfully returned',
    type: AppResDto,
  })
  getHello(@Body() dto: AppReqDto): AppResDto {
    return this.appService.getHello(dto);
  }
}
